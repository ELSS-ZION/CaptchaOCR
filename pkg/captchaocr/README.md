# CaptchaOCR Go 包

这个包提供了验证码识别功能，基于 Python 的 ddddocr 库，通过 CGO 实现 Go 与 Python 的交互。

## 快速开始

### 1. 安装

首先，确保已安装基本依赖：

- Go (1.18+)
- Python 3.7+
- Python 开发头文件（Python.h）
  - Debian/Ubuntu: `apt-get install python3-dev`
  - CentOS/RHEL: `yum install python3-devel`
  - macOS: 通常随 Python 安装包提供

在您的项目中，运行以下命令获取 CaptchaOCR：

```bash
go get github.com/ELSS-ZION/CaptchaOCR
```

### 2. 设置

运行安装脚本来设置必要的环境：

```bash
cd $GOPATH/pkg/mod/github.com/ELSS-ZION/CaptchaOCR@<version>/pkg/captchaocr
chmod +x setup.sh
./setup.sh
```

此脚本会：
- 安装所需的 Python 依赖
- 编译 C 包装器代码
- 显示编译您项目所需的环境变量

### 3. 编译您的项目

按照安装脚本输出的指示，设置环境变量并编译您的项目：

```bash
# 设置环境变量（使用setup.sh输出的实际值）
export CGO_CFLAGS="-I/path/to/python/include"
export CGO_LDFLAGS="-L/path/to/python/lib -lpythonX.Y -Wl,-force_load,/path/to/python_wrapper.o"

# 编译您的项目
go build -o yourapp main.go
```

## 使用示例

```go
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

## API 参考

### `captchaocr.Initialize() error`

初始化验证码识别环境，必须在使用其他函数前调用。

### `captchaocr.Cleanup()`

清理验证码识别环境，应在程序结束前调用。

### `captchaocr.RecognizeCaptcha(imageData string) (string, error)`

识别 BASE64 编码的验证码图片，并返回识别结果。

- `imageData`: BASE64 编码的图片数据
- 返回值: 识别出的验证码文字，如果识别失败则返回错误 