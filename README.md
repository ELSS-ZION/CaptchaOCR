# CaptchaOCR

CaptchaOCR是一个使用Go和Python结合实现的验证码识别库，利用了ddddocr来识别验证码。

## 特点

- 封装ddddocr库，使Go程序能够方便地调用
- Python代码直接嵌入到C代码中，无需外部脚本文件
- 简单易用的API接口
- 包含完整的示例代码

## 安装和使用

只需两个简单步骤即可在您的Go项目中使用CaptchaOCR：

1. 在您的Go项目中添加依赖：
   ```bash
   # 获取最新版本
   go get github.com/ELSS-ZION/CaptchaOCR@latest
   
   # 或者获取特定版本
   go get github.com/ELSS-ZION/CaptchaOCR@v1.0.1
   ```

2. 下载并使用构建脚本：
   ```bash
   curl -sSL https://raw.githubusercontent.com/ELSS-ZION/CaptchaOCR/main/build.sh -o build.sh
   chmod +x build.sh
   ./build.sh -o yourapp
   ```

构建脚本会自动：
- 安装必要的Python依赖（ddddocr）
- 编译Python包装器
- 设置正确的CGO环境变量
- 编译您的项目

## 代码示例

```go
package main

import (
    "fmt"
    "os"

    "github.com/ELSS-ZION/CaptchaOCR"
)

func main() {
    // 初始化
    err := captchaocr.Initialize()
    if err != nil {
        fmt.Printf("初始化失败: %v\n", err)
        os.Exit(1)
    }
    defer captchaocr.Cleanup()

    // 识别验证码（base64图片数据）
    result, err := captchaocr.RecognizeCaptcha(imageBase64)
    if err != nil {
        fmt.Printf("识别失败: %v\n", err)
        os.Exit(1)
    }

    fmt.Printf("验证码识别结果: %s\n", result)
}
```

## 系统要求

- Go 1.21+
- Python 3.6+
- GCC 编译器

## 注意事项

- 本库使用CGO与Python交互，确保您的系统已正确配置
- 调用 `Initialize()` 初始化库，使用完毕后调用 `Cleanup()` 清理资源
- 图片数据需要是base64编码
- 所有的Python代码已经嵌入到C代码中，无需外部Python脚本文件

## 许可证

MIT License 