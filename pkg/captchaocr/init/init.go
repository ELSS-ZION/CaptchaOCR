// Package init 自动初始化 CaptchaOCR
package init

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"

	// 添加一个匿名导入，用于触发CGO初始化
	_ "github.com/ELSS-ZION/CaptchaOCR/pkg/captchaocr"
)

func init() {
	// 获取当前包的路径
	_, file, _, _ := runtime.Caller(0)
	pkgDir := filepath.Dir(filepath.Dir(file))

	// 设置脚本路径
	setupScript := filepath.Join(pkgDir, "setup.sh")

	// 确保脚本可执行
	os.Chmod(setupScript, 0755)

	// 执行安装脚本
	cmd := exec.Command("/bin/bash", setupScript)
	output, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Printf("初始化失败: %v\n%s\n", err, output)
	} else {
		fmt.Println("CaptchaOCR 依赖初始化成功")
	}
}
