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
go get github.com/ELSS-ZION/CaptchaOCR@v0.3.0
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

1. **使用自动生成的构建脚本** (最简单):

```bash
# 找到库的安装位置
CAPTCHAOCR_PATH=$(go list -m -json github.com/ELSS-ZION/CaptchaOCR | grep "Dir" | cut -d '"' -f4)

# 使用自动生成的构建脚本
cd $CAPTCHAOCR_PATH/pkg/captchaocr
./build.sh 您的应用名称 您的main.go文件路径
```

2. **手动设置编译环境**:

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
go get github.com/ELSS-ZION/CaptchaOCR@v0.3.0
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

您可以使用两种方法编译项目：

- **使用生成的构建脚本**:

```bash
cd $CAPTCHAOCR_PATH/pkg/captchaocr
./build.sh 您的应用名称 您的main.go文件路径
```

- **手动设置环境变量**:

```bash
# 使用setup.sh输出的实际值
export CGO_CFLAGS="-I${PYTHON_PATH}/include/python${PYTHON_VERSION}"
export CGO_LDFLAGS="-L${PYTHON_PATH}/lib -lpython${PYTHON_VERSION} -Wl,-force_load,${CAPTCHAOCR_PATH}/build/python_wrapper.o,-no_warn_duplicate_libraries"

# 编译您的项目
go build -o 您的应用名称 main.go
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

### 问题：编译时找不到头文件或链接错误

确保您已经正确设置了 CGO 环境变量，并且使用了正确的 Python 路径。最简单的方法是使用自动生成的 build.sh 脚本进行编译。

### 问题：运行时找不到 Python 模块

确保您已经正确安装了所需的 Python 依赖，并且 Python 路径设置正确。库会自动尝试寻找正确的 Python 脚本路径。

### 问题：macOS 上的链接问题

在 macOS 上可能需要额外的链接标志，如果遇到链接问题，请尝试添加以下标志：

```bash
export CGO_LDFLAGS="-L${PYTHON_PATH}/lib -lpython${PYTHON_VERSION} -Wl,-force_load,${CAPTCHAOCR_PATH}/build/python_wrapper.o,-no_warn_duplicate_libraries"
```

## 许可证

MIT 许可证 