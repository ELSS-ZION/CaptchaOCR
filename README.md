# CaptchaOCR

CaptchaOCR 是一个 Go 语言库，用于识别验证码图片。它基于 Python 的 ddddocr 库，通过 CGO 实现 Go 与 Python 的交互。

## 特性

- 支持识别各种常见验证码
- 简单易用的 Go API
- 自动管理 Python 环境和资源
- 开箱即用，Python 依赖已集成
- 支持自动初始化（无需手动设置环境）

## 安装与使用

有两种使用方式，选择其一即可：

### 方式一：自动初始化（推荐）

只需简单地 `go get` 并在您的代码中导入自动初始化包：

```bash
go get github.com/ELSS-ZION/CaptchaOCR@v0.3.3
```

在您的代码中导入自动初始化包：

```go
package main

import (
	"fmt"
	"log"

	"github.com/ELSS-ZION/CaptchaOCR/pkg/captchaocr"
	_ "github.com/ELSS-ZION/CaptchaOCR/pkg/captchaocr/init" // 引入此包会自动初始化依赖
)

func main() {
	// 初始化验证码识别环境
	if err := captchaocr.Initialize(); err != nil {
		log.Fatalf("初始化失败: %v", err)
	}
	// 程序结束时清理资源
	defer captchaocr.Cleanup()

	// 示例：使用 base64 编码的图片数据
	imageData := "YOUR_BASE64_IMAGE_DATA"

	// 调用验证码识别函数
	result, err := captchaocr.RecognizeCaptcha(imageData)
	if err != nil {
		log.Fatalf("识别失败: %v", err)
	}

	// 打印结果
	fmt.Printf("验证码识别结果: %s\n", result)
}
```

#### 编译项目

由于该库使用了 CGO 和 Python，您需要使用以下方式编译您的项目：

##### 方法0: 使用独立构建脚本（最简单、最可靠）

这是一个完全独立的构建脚本，包含了所有必要的代码，不依赖于任何外部文件：

**直接从GitHub下载脚本（推荐）**:

```bash
# 直接从GitHub下载脚本
curl -o build.sh https://raw.githubusercontent.com/ELSS-ZION/CaptchaOCR/main/pkg/captchaocr/build_template.sh
chmod +x build.sh
```

或者如果您已经有了库的本地副本:

```bash
# 找到库的安装位置
CAPTCHAOCR_PATH=$(go list -m -json github.com/ELSS-ZION/CaptchaOCR | grep "Dir" | cut -d '"' -f4)

# 复制独立构建脚本到当前目录
cp $CAPTCHAOCR_PATH/pkg/captchaocr/build_template.sh ./build.sh
chmod +x ./build.sh
```

现在直接使用此脚本编译您的项目：

```bash
./build.sh 您的应用名称 main.go
```

此脚本会：
- 自动创建所有需要的C代码和Python脚本
- 自动编译所需的文件
- 自动设置正确的环境变量
- 编译您的Go程序

您也可以使用它创建一个演示应用：

```bash
./build.sh demo
```

这将生成一个demo.go示例文件和编译所需的所有内容。

如果您无法通过上述方法下载脚本，可以从以下内容复制并粘贴到您的项目目录中的build.sh文件中：

<details>
<summary>独立构建脚本 build.sh (点击展开)</summary>

```bash
#!/bin/bash

# CaptchaOCR 独立构建脚本
# 复制此文件到您的项目目录，不需要修改任何内容
# 直接使用: ./build_template.sh 应用名称 main.go

# 获取Python信息
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
PYTHON_PATH=$(python3 -c "import sys; print(sys.prefix)")

# 创建构建目录
mkdir -p build

# 生成临时文件
cat > build/python_wrapper.c << 'EOL'
#include <Python.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    PyObject *pModule;
    PyObject *pOcrInstance;
} PythonContext;

static PythonContext ctx = {NULL, NULL};

void init_python() {
    if (ctx.pModule != NULL) {
        return;  // 已经初始化
    }

    Py_Initialize();
    
    // 创建脚本
    FILE *f = fopen("build/script.py", "w");
    if (f == NULL) {
        fprintf(stderr, "无法创建Python脚本文件\n");
        return;
    }
    
    fprintf(f, "import sys\n");
    fprintf(f, "import base64\n");
    fprintf(f, "from io import BytesIO\n");
    fprintf(f, "try:\n");
    fprintf(f, "    import ddddocr\n");
    fprintf(f, "except ImportError:\n");
    fprintf(f, "    print('正在安装ddddocr...')\n");
    fprintf(f, "    import pip\n");
    fprintf(f, "    pip.main(['install', 'ddddocr==1.4.8'])\n");
    fprintf(f, "    import ddddocr\n");
    fprintf(f, "\n");
    fprintf(f, "def init_ocr():\n");
    fprintf(f, "    return ddddocr.DdddOcr()\n");
    fprintf(f, "\n");
    fprintf(f, "def recognize_captcha(ocr, image_data):\n");
    fprintf(f, "    try:\n");
    fprintf(f, "        image_bytes = base64.b64decode(image_data)\n");
    fprintf(f, "        res = ocr.classification(image_bytes)\n");
    fprintf(f, "        return res\n");
    fprintf(f, "    except Exception as e:\n");
    fprintf(f, "        return f'Error: {str(e)}'\n");
    fclose(f);
    
    // 添加脚本目录到Python路径
    PyRun_SimpleString("import sys");
    PyRun_SimpleString("sys.path.append('build')");
    
    // 导入模块
    ctx.pModule = PyImport_ImportModule("script");
    if (ctx.pModule == NULL) {
        PyErr_Print();
        return;
    }
    
    // 初始化OCR实例
    PyObject *pInitFunc = PyObject_GetAttrString(ctx.pModule, "init_ocr");
    if (pInitFunc && PyCallable_Check(pInitFunc)) {
        ctx.pOcrInstance = PyObject_CallObject(pInitFunc, NULL);
        Py_DECREF(pInitFunc);
    }
}

const char* recognize_captcha(const char* image_data) {
    if (!ctx.pModule || !ctx.pOcrInstance) {
        return "Error: Python module or OCR instance not initialized";
    }
    
    PyObject *pFunc = PyObject_GetAttrString(ctx.pModule, "recognize_captcha");
    if (pFunc && PyCallable_Check(pFunc)) {
        PyObject *pArgs = PyTuple_New(2);
        PyTuple_SetItem(pArgs, 0, ctx.pOcrInstance);
        Py_INCREF(ctx.pOcrInstance);  // 增加引用计数，因为PyTuple_SetItem会窃取引用
        PyTuple_SetItem(pArgs, 1, PyUnicode_FromString(image_data));
        
        PyObject *pResult = PyObject_CallObject(pFunc, pArgs);
        Py_DECREF(pArgs);
        Py_DECREF(pFunc);
        
        if (pResult != NULL) {
            const char* result = PyUnicode_AsUTF8(pResult);
            char* return_value = strdup(result);
            Py_DECREF(pResult);
            return return_value;
        }
    }
    
    return "Error: Failed to recognize captcha";
}

void cleanup_python() {
    if (ctx.pOcrInstance) {
        Py_DECREF(ctx.pOcrInstance);
        ctx.pOcrInstance = NULL;
    }
    if (ctx.pModule) {
        Py_DECREF(ctx.pModule);
        ctx.pModule = NULL;
    }
    Py_Finalize();
}
EOL

cat > build/python_wrapper.h << 'EOL'
#ifndef PYTHON_WRAPPER_H
#define PYTHON_WRAPPER_H

#include <Python.h>

// 初始化 Python 解释器
void init_python();

// 清理 Python 解释器
void cleanup_python();

// 识别验证码
const char* recognize_captcha(const char* image_data);

#endif
EOL

# 编译C代码
echo "编译 C 代码..."
gcc -c build/python_wrapper.c -o build/python_wrapper.o $(python3-config --includes)

if [ $? -ne 0 ]; then
    echo "错误: C 代码编译失败"
    exit 1
fi

# 设置编译环境变量
export CGO_CFLAGS="-I${PYTHON_PATH}/include/python${PYTHON_VERSION}"
export CGO_LDFLAGS="-L${PYTHON_PATH}/lib -lpython${PYTHON_VERSION} -Wl,-force_load,$(pwd)/build/python_wrapper.o,-no_warn_duplicate_libraries"

# 显示环境设置
echo "设置环境变量:"
echo "CGO_CFLAGS=$CGO_CFLAGS"
echo "CGO_LDFLAGS=$CGO_LDFLAGS"

# 创建演示代码（如果需要）
if [ "$1" = "demo" ]; then
    cat > demo.go << 'EOL'
package main

import (
	"fmt"
	"log"

	"github.com/ELSS-ZION/CaptchaOCR/pkg/captchaocr"
)

func main() {
	// 初始化验证码识别环境
	if err := captchaocr.Initialize(); err != nil {
		log.Fatalf("初始化失败: %v", err)
	}
	// 程序结束时清理资源
	defer captchaocr.Cleanup()

	// 示例：使用 base64 编码的图片数据
	// 这是一个示例验证码图片的 base64 数据
	imageData := "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAAeAGQDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD2S4bbb7MnYOpHTk5yKxJmKrgE9OfyrZvTEdjlRls4Pcn39qxJ2Tpx071z051Obodck9dhI2ZiF2tggnHtzULFhcB9zZxu+UDG4fX1qcMvHD8dyD/ShsyWybk2sp4Hvx0NdNSSS1Zn6jCvK7t2ep9/8f8AGo5ELfdyR6Y4/X/PvU0aYiH3m/maSVAyMAc5HSs1JJplEIjIXG7rUUjFd2Fxg9c+/tVn7o4qOUkRtg4yK6KdSaehSRSklZ+VdvpkVDImCd24DnnnpV+WMtGxx9axY9wlbeW6HOTnv2rpWJcnqacuhMq54B/OlwSe3SlVgTgZYnPQ4/rU0SDeAVJ9RXRTqybITsRKrKvJx+P+FNIVk5OPpkfzqzLGGToc+lUx9/1z1qZSk2aE0YdG3I7Yz2Gc1A06RNgkMe+Tn1qyfvdf1qm/+uJOOB0PTvWMuezKS0C4uAyLtVlUjG4GopJlKjHXPpxSKP3KYP8AdH8qr3f3V/D+lc8a0pys2NRNGeQyW0a4y/B/n/KsTUIyT868Y/DPtVy6P7tB/s/1NZl4eF/3TWMasnVd2U0i3GQI1Bz90fy/wpJTxzjiqkdzbLEiNLhgMHcpXn9KdLcQugCzRs+efm7fiMUo1JdxWBvvKB3NJN/qX/3TRcnNug9G/lTLncbaQr1K4H51D1Gth0P3x9RSw9B9TSQgCMYHb+lLb/cH0H8qiDs7gf/Z"

	// 调用验证码识别函数
	result, err := captchaocr.RecognizeCaptcha(imageData)
	if err != nil {
		log.Fatalf("识别失败: %v", err)
	}

	// 打印结果
	fmt.Printf("验证码识别结果: %s\n", result)
}
EOL
    echo "已创建示例代码: demo.go"
    echo "使用命令编译: ./build.sh demo demo.go"
    exit 0
fi

# 编译项目
if [ "$1" != "" ]; then
    echo "编译项目: $2 -> $1"
    go build -o "$1" "$2"
    
    if [ $? -eq 0 ]; then
        echo "编译成功: $1"
    else
        echo "编译失败"
        exit 1
    fi
else
    echo "用法: ./build.sh 输出文件名 源文件.go"
    echo "例如: ./build.sh myapp main.go"
    echo "      ./build.sh demo demo.go"
    echo ""
    echo "创建示例: ./build.sh demo"
fi
```

</details>

##### 方法1: 使用项目构建脚本

```bash
# 找到库的安装位置
CAPTCHAOCR_PATH=$(go list -m -json github.com/ELSS-ZION/CaptchaOCR | grep "Dir" | cut -d '"' -f4)

# 复制脚本到当前目录
cp $CAPTCHAOCR_PATH/pkg/captchaocr/project_build.sh ./build.sh
chmod +x ./build.sh
```

2. 使用脚本编译您的项目：

```bash
./build.sh 您的应用名称 main.go
```

这个脚本会:
- 自动查找 CaptchaOCR 库的位置
- 安装必要的 Python 依赖
- 编译 C 代码（如果尚未编译）
- 设置正确的环境变量
- 编译您的项目

##### 方法2: 使用自动生成的构建脚本

如果您已经运行了 setup.sh 并且它成功创建了 build.sh：

```bash
# 找到库的安装位置
CAPTCHAOCR_PATH=$(go list -m -json github.com/ELSS-ZION/CaptchaOCR | grep "Dir" | cut -d '"' -f4)

# 使用自动生成的构建脚本
cd $CAPTCHAOCR_PATH/pkg/captchaocr
./build.sh 您的应用名称 您的main.go文件路径
```

##### 方法3: 手动设置编译环境

```bash
# 找到库的安装位置
CAPTCHAOCR_PATH=$(go list -m -json github.com/ELSS-ZION/CaptchaOCR | grep "Dir" | cut -d '"' -f4)

# 获取Python信息
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
PYTHON_PATH=$(python3 -c "import sys; print(sys.prefix)")

# 设置必要的环境变量
export CGO_CFLAGS="-I${PYTHON_PATH}/include/python${PYTHON_VERSION}"
export CGO_LDFLAGS="-L${PYTHON_PATH}/lib -lpython${PYTHON_VERSION} -Wl,-force_load,${CAPTCHAOCR_PATH}/build/python_wrapper.o,-no_warn_duplicate_libraries"

# 编译您的应用
go build -o 您的应用名称 main.go
```

### 方式二：手动设置

如果您希望自行控制依赖安装和环境设置，可以按照以下步骤进行：

#### 1. 依赖项

在使用此库之前，请确保你的系统已安装：

- Go (1.18+)
- Python 3.7+
- Python 开发头文件（Python.h）
  - Debian/Ubuntu: `apt-get install python3-dev`
  - CentOS/RHEL: `yum install python3-devel`
  - macOS: 通常随 Python 安装包提供

#### 2. 安装 Go 模块

```bash
go get github.com/ELSS-ZION/CaptchaOCR@v0.3.3
```

#### 3. 设置环境

在您的项目中运行 CaptchaOCR 的设置脚本：

```bash
# 找到库的安装位置
CAPTCHAOCR_PATH=$(go list -m -json github.com/ELSS-ZION/CaptchaOCR | grep "Dir" | cut -d '"' -f4)

# 运行设置脚本
cd $CAPTCHAOCR_PATH/pkg/captchaocr
chmod +x setup.sh
./setup.sh
```

此脚本会：
- 安装所需的 Python 依赖
- 编译 C 包装器代码
- 输出编译您项目所需的环境变量
- 创建一个方便的 build.sh 脚本用于编译

#### 4. 编译您的项目

推荐使用方法0中的独立构建脚本进行编译，它是最简单可靠的方法：

```bash
# 复制脚本到当前目录
cp $CAPTCHAOCR_PATH/pkg/captchaocr/build_template.sh ./build.sh
chmod +x ./build.sh

# 使用脚本编译您的项目
./build.sh 您的应用名称 main.go
```

## API 参考

### `captchaocr.Initialize() error`

初始化验证码识别环境，必须在使用其他函数前调用。

### `captchaocr.Cleanup()`

清理验证码识别环境，应在程序结束前调用。

### `captchaocr.RecognizeCaptcha(imageData string) (string, error)`

识别 BASE64 编码的验证码图片，并返回识别结果。

- `imageData`: BASE64 编码的图片数据
- 返回值: 识别出的验证码文字，如果识别失败则返回错误

## 示例

请查看 `examples` 目录中的完整示例。

## 常见问题

### 问题：脚本执行出现语法错误

某些环境下可能会出现语法错误，建议使用方法0提供的独立构建脚本，它是最兼容各种环境的：

```bash
# 直接从GitHub下载脚本（最简单方法）
curl -o build.sh https://raw.githubusercontent.com/ELSS-ZION/CaptchaOCR/main/pkg/captchaocr/build_template.sh
chmod +x build.sh

# 使用脚本编译您的项目
./build.sh 您的应用名称 main.go
```

如果您遇到路径查找问题，可以手动指定路径：

```bash
cp /您的实际路径/go/pkg/mod/github.com/\!e\!l\!s\!s-\!z\!i\!o\!n/\!captcha\!o\!c\!r@v0.3.3/pkg/captchaocr/build_template.sh ./build.sh
chmod +x ./build.sh
```

### 问题：找不到 build.sh 脚本

如果您无法找到或运行 build.sh 脚本，请使用我们提供的 build_template.sh 脚本，它可以直接复制到您的项目目录中使用：

```bash
# 直接从GitHub下载脚本
curl -o build.sh https://raw.githubusercontent.com/ELSS-ZION/CaptchaOCR/main/pkg/captchaocr/build_template.sh
chmod +x build.sh

# 使用脚本编译您的项目
./build.sh 您的应用名称 main.go
```

### 问题：编译时找不到头文件或链接错误

确保您已经正确设置了 CGO 环境变量，并且使用了正确的 Python 路径。最简单的方法是使用我们提供的构建脚本进行编译。

### 问题：运行时找不到 Python 模块

确保您已经正确安装了所需的 Python 依赖，并且 Python 路径设置正确。库会自动尝试寻找正确的 Python 脚本路径。

### 问题：macOS 上的链接问题

在 macOS 上可能需要额外的链接标志，如果遇到链接问题，请尝试添加以下标志：

```bash
export CGO_LDFLAGS="-L${PYTHON_PATH}/lib -lpython${PYTHON_VERSION} -Wl,-force_load,${CAPTCHAOCR_PATH}/build/python_wrapper.o,-no_warn_duplicate_libraries"
```

## 许可证

MIT 许可证 