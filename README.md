# CaptchaOCR

CaptchaOCR是一个使用Go和Python结合实现的验证码识别库，利用了ddddocr来识别验证码。

## 安装

1. 确保您已安装以下依赖：
   - Go 1.21+
   - Python 3.6+
   - GCC

2. 克隆本仓库：
   ```bash
   git clone https://your-repo-url/captchaocr.git
   cd captchaocr
   ```

3. 运行安装脚本：
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

## 使用方法

1. 在您的Go项目中导入此包：
   ```go
   import "captchaocr"
   ```

2. 使用编译脚本编译您的项目：
   ```bash
   /path/to/captchaocr/build/build.sh -o yourapp
   ```

3. 在您的代码中使用：
   ```go
   package main

   import (
       "fmt"
       "captchaocr"
   )

   func main() {
       // 初始化
       err := captchaocr.Initialize()
       if err != nil {
           panic(err)
       }
       defer captchaocr.Cleanup()

       // 识别验证码（base64图片数据）
       result, err := captchaocr.RecognizeCaptcha(imageBase64)
       if err != nil {
           panic(err)
       }

       fmt.Println("识别结果:", result)
   }
   ```

## 示例

查看 `examples/main.go` 获取完整示例。

## 注意事项

- 本库使用CGO与Python交互，确保您的系统已正确配置
- 调用 `Initialize()` 初始化库，使用完毕后调用 `Cleanup()` 清理资源
- 图片数据需要是base64编码 