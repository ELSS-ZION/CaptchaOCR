// Package captchaocr 提供验证码识别功能，基于Python的ddddocr库
package captchaocr

/*
#cgo pkg-config: python3
#include "../../python/wrapper/python_wrapper.h"
#include <stdlib.h>
*/
import "C"
import (
	"errors"
	"sync"
	"unsafe"
)

var (
	initOnce sync.Once
	initErr  error
)

// Initialize 初始化验证码识别环境，必须在使用其他函数前调用
func Initialize() error {
	initOnce.Do(func() {
		C.init_python()
	})
	return initErr
}

// Cleanup 清理验证码识别环境，应用程序结束前调用
func Cleanup() {
	C.cleanup_python()
}

// RecognizeCaptcha 识别BASE64编码的验证码图片
// imageData 为BASE64编码的图片数据
// 返回识别结果或错误
func RecognizeCaptcha(imageData string) (string, error) {
	cImageData := C.CString(imageData)
	defer C.free(unsafe.Pointer(cImageData))

	result := C.recognize_captcha(cImageData)
	defer C.free(unsafe.Pointer(result))

	resultStr := C.GoString(result)

	// 检查是否包含错误信息
	if len(resultStr) > 6 && resultStr[:6] == "Error:" {
		return "", errors.New(resultStr)
	}

	return resultStr, nil
}
