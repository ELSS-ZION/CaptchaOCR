package captchaocr

/*
#cgo pkg-config: python3
#include "pkg/python/wrapper/python_wrapper.h"
#include <stdlib.h>
*/
import "C"
import (
	"errors"
	"sync"
	"unsafe"
)

var (
	initialized   bool
	initializeMux sync.Mutex
)

// Initialize 初始化Python解释器和OCR引擎
func Initialize() error {
	initializeMux.Lock()
	defer initializeMux.Unlock()

	if initialized {
		return nil
	}

	C.init_python()
	initialized = true
	return nil
}

// RecognizeCaptcha 识别验证码图片
// imageData 参数应该是base64编码的图片数据
func RecognizeCaptcha(imageData string) (string, error) {
	if !initialized {
		return "", errors.New("captchaocr not initialized, call Initialize() first")
	}

	cImageData := C.CString(imageData)
	defer C.free(unsafe.Pointer(cImageData))

	result := C.recognize_captcha(cImageData)
	defer C.free(unsafe.Pointer(result))

	return C.GoString(result), nil
}
