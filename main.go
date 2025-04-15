package main

/*
#cgo pkg-config: python3
#include "python_wrapper.h"
*/
import "C"
import (
	"fmt"
)

func main() {
	// 初始化 Python 解释器
	C.init_python()
	defer C.cleanup_python()

	// 调用 Python 函数
	result := C.call_python_add(C.int(5), C.int(3))
	fmt.Printf("5 + 3 = %d\n", result)
}
