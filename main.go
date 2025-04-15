package main

/*
#cgo pkg-config: python3
#include "python_wrapper.h"
#include <stdlib.h>
*/
import "C"
import (
	"fmt"
	"unsafe"
)

func main() {
	// 初始化 Python
	C.init_python()
	defer C.cleanup_python()

	// 示例：使用 base64 编码的图片数据
	imageData := "iVBORw0KGgoAAAANSUhEUgAA..." // 这里需要替换为实际的 base64 图片数据
	cImageData := C.CString(imageData)
	defer C.free(unsafe.Pointer(cImageData))

	// 识别验证码
	result := C.recognize_captcha(cImageData)
	defer C.free(unsafe.Pointer(result))

	// 打印结果
	fmt.Printf("验证码识别结果: %s\n", C.GoString(result))
}
