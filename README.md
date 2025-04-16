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
go get github.com/ELSS-ZION/CaptchaOCR
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
go get github.com/ELSS-ZION/CaptchaOCR
```

#### 3. 设置环境

在您的项目中运行 CaptchaOCR 的设置脚本：

```bash
cd $GOPATH/pkg/mod/github.com/ELSS-ZION/CaptchaOCR@<version>/pkg/captchaocr
chmod +x setup.sh
./setup.sh
```

此脚本会：
- 安装所需的 Python 依赖
- 编译 C 包装器代码
- 输出编译您项目所需的环境变量

#### 4. 编译您的项目

在编译项目前，设置必要的环境变量（使用 setup.sh 输出的实际值）：

```bash
export CGO_CFLAGS="-I/path/to/python/include"
export CGO_LDFLAGS="-L/path/to/python/lib -lpythonX.Y -Wl,-force_load,/path/to/python_wrapper.o"

go build -o yourapp main.go
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

## 许可证

MIT 许可证 