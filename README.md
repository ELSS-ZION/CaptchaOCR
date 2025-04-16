# CaptchaOCR

CaptchaOCR 是一个 Go 语言库，用于识别验证码图片。它基于 Python 的 ddddocr 库，通过 CGO 实现 Go 与 Python 的交互。

## 特性

- 支持识别各种常见验证码
- 简单易用的 Go API
- 自动管理 Python 环境和资源

## 安装

### 1. 依赖项

在使用此库之前，请确保你的系统已安装：

- Go (1.18+)
- Python 3.7+
- Python 开发头文件（Python.h）
  - Debian/Ubuntu: `apt-get install python3-dev`
  - CentOS/RHEL: `yum install python3-devel`
  - macOS: 通常随 Python 安装包提供

### 2. 安装 Go 模块

```bash
go get github.com/yourusername/captchaocr
```

### 3. 安装 Python 依赖

项目根目录下的 `python/requirements.txt` 包含所需的 Python 依赖：

```bash
pip install -r python/requirements.txt
```

主要的 Python 依赖是 `ddddocr`，它提供底层的验证码识别功能。

## 使用方法

```go
package main

import (
	"fmt"
	"log"

	"github.com/yourusername/captchaocr/pkg/captchaocr"
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

## 示例

请查看 `examples` 目录中的完整示例。

## 许可证

MIT 许可证 