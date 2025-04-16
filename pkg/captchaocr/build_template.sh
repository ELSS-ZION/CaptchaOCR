#!/bin/bash

# CaptchaOCR 独立构建脚本
# 复制此文件到您的项目目录，不需要修改任何内容
# 直接使用: ./build_template.sh 应用名称 main.go

# 获取Python信息
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
PYTHON_PATH=$(python3 -c "import sys; print(sys.prefix)")

# 创建构建目录
mkdir -p build

# 生成临时文件
cat > build/python_wrapper.c << 'EOL'
#include <Python.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    PyObject *pModule;
    PyObject *pOcrInstance;
} PythonContext;

static PythonContext ctx = {NULL, NULL};

void init_python() {
    if (ctx.pModule != NULL) {
        return;  // 已经初始化
    }

    Py_Initialize();
    
    // 创建脚本
    FILE *f = fopen("build/script.py", "w");
    if (f == NULL) {
        fprintf(stderr, "无法创建Python脚本文件\n");
        return;
    }
    
    fprintf(f, "import sys\n");
    fprintf(f, "import base64\n");
    fprintf(f, "from io import BytesIO\n");
    fprintf(f, "try:\n");
    fprintf(f, "    import ddddocr\n");
    fprintf(f, "except ImportError:\n");
    fprintf(f, "    print('正在安装ddddocr...')\n");
    fprintf(f, "    import pip\n");
    fprintf(f, "    pip.main(['install', 'ddddocr==1.4.8'])\n");
    fprintf(f, "    import ddddocr\n");
    fprintf(f, "\n");
    fprintf(f, "def init_ocr():\n");
    fprintf(f, "    return ddddocr.DdddOcr()\n");
    fprintf(f, "\n");
    fprintf(f, "def recognize_captcha(ocr, image_data):\n");
    fprintf(f, "    try:\n");
    fprintf(f, "        image_bytes = base64.b64decode(image_data)\n");
    fprintf(f, "        res = ocr.classification(image_bytes)\n");
    fprintf(f, "        return res\n");
    fprintf(f, "    except Exception as e:\n");
    fprintf(f, "        return f'Error: {str(e)}'\n");
    fclose(f);
    
    // 添加脚本目录到Python路径
    PyRun_SimpleString("import sys");
    PyRun_SimpleString("sys.path.append('build')");
    
    // 导入模块
    ctx.pModule = PyImport_ImportModule("script");
    if (ctx.pModule == NULL) {
        PyErr_Print();
        return;
    }
    
    // 初始化OCR实例
    PyObject *pInitFunc = PyObject_GetAttrString(ctx.pModule, "init_ocr");
    if (pInitFunc && PyCallable_Check(pInitFunc)) {
        ctx.pOcrInstance = PyObject_CallObject(pInitFunc, NULL);
        Py_DECREF(pInitFunc);
    }
}

const char* recognize_captcha(const char* image_data) {
    if (!ctx.pModule || !ctx.pOcrInstance) {
        return "Error: Python module or OCR instance not initialized";
    }
    
    PyObject *pFunc = PyObject_GetAttrString(ctx.pModule, "recognize_captcha");
    if (pFunc && PyCallable_Check(pFunc)) {
        PyObject *pArgs = PyTuple_New(2);
        PyTuple_SetItem(pArgs, 0, ctx.pOcrInstance);
        Py_INCREF(ctx.pOcrInstance);  // 增加引用计数，因为PyTuple_SetItem会窃取引用
        PyTuple_SetItem(pArgs, 1, PyUnicode_FromString(image_data));
        
        PyObject *pResult = PyObject_CallObject(pFunc, pArgs);
        Py_DECREF(pArgs);
        Py_DECREF(pFunc);
        
        if (pResult != NULL) {
            const char* result = PyUnicode_AsUTF8(pResult);
            char* return_value = strdup(result);
            Py_DECREF(pResult);
            return return_value;
        }
    }
    
    return "Error: Failed to recognize captcha";
}

void cleanup_python() {
    if (ctx.pOcrInstance) {
        Py_DECREF(ctx.pOcrInstance);
        ctx.pOcrInstance = NULL;
    }
    if (ctx.pModule) {
        Py_DECREF(ctx.pModule);
        ctx.pModule = NULL;
    }
    Py_Finalize();
}
EOL

cat > build/python_wrapper.h << 'EOL'
#ifndef PYTHON_WRAPPER_H
#define PYTHON_WRAPPER_H

#include <Python.h>

// 初始化 Python 解释器
void init_python();

// 清理 Python 解释器
void cleanup_python();

// 识别验证码
const char* recognize_captcha(const char* image_data);

#endif
EOL

# 编译C代码
echo "编译 C 代码..."
gcc -c build/python_wrapper.c -o build/python_wrapper.o $(python3-config --includes)

if [ $? -ne 0 ]; then
    echo "错误: C 代码编译失败"
    exit 1
fi

# 设置编译环境变量
export CGO_CFLAGS="-I${PYTHON_PATH}/include/python${PYTHON_VERSION}"
export CGO_LDFLAGS="-L${PYTHON_PATH}/lib -lpython${PYTHON_VERSION} -Wl,-force_load,$(pwd)/build/python_wrapper.o,-no_warn_duplicate_libraries"

# 显示环境设置
echo "设置环境变量:"
echo "CGO_CFLAGS=$CGO_CFLAGS"
echo "CGO_LDFLAGS=$CGO_LDFLAGS"

# 创建演示代码（如果需要）
if [ "$1" = "demo" ]; then
    cat > demo.go << 'EOL'
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
	// 这是一个示例验证码图片的 base64 数据
	imageData := "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAAeAGQDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD2S4bbb7MnYOpHTk5yKxJmKrgE9OfyrZvTEdjlRls4Pcn39qxJ2Tpx071z051Obodck9dhI2ZiF2tggnHtzULFhcB9zZxu+UDG4fX1qcMvHD8dyD/ShsyWybk2sp4Hvx0NdNSSS1Zn6jCvK7t2ep9/8f8AGo5ELfdyR6Y4/X/PvU0aYiH3m/maSVAyMAc5HSs1JJplEIjIXG7rUUjFd2Fxg9c+/tVn7o4qOUkRtg4yK6KdSaehSRSklZ+VdvpkVDImCd24DnnnpV+WMtGxx9axY9wlbeW6HOTnv2rpWJcnqacuhMq54B/OlwSe3SlVgTgZYnPQ4/rU0SDeAVJ9RXRTqybITsRKrKvJx+P+FNIVk5OPpkfzqzLGGToc+lUx9/1z1qZSk2aE0YdG3I7Yz2Gc1A06RNgkMe+Tn1qyfvdf1qm/+uJOOB0PTvWMuezKS0C4uAyLtVlUjG4GopJlKjHXPpxSKP3KYP8AdH8qr3f3V/D+lc8a0pys2NRNGeQyW0a4y/B/n/KsTUIyT868Y/DPtVy6P7tB/s/1NZl4eF/3TWMasnVd2U0i3GQI1Bz90fy/wpJTxzjiqkdzbLEiNLhgMHcpXn9KdLcQugCzRs+efm7fiMUo1JdxWBvvKB3NJN/qX/3TRcnNug9G/lTLncbaQr1K4H51D1Gth0P3x9RSw9B9TSQgCMYHb+lLb/cH0H8qiDs7gf/Z"

	// 调用验证码识别函数
	result, err := captchaocr.RecognizeCaptcha(imageData)
	if err != nil {
		log.Fatalf("识别失败: %v", err)
	}

	// 打印结果
	fmt.Printf("验证码识别结果: %s\n", result)
}
EOL
    echo "已创建示例代码: demo.go"
    echo "使用命令编译: ./build_template.sh demo demo.go"
    exit 0
fi

# 编译项目
if [ "$1" != "" ]; then
    echo "编译项目: $2 -> $1"
    go build -o "$1" "$2"
    
    if [ $? -eq 0 ]; then
        echo "编译成功: $1"
    else
        echo "编译失败"
        exit 1
    fi
else
    echo "用法: ./build_template.sh 输出文件名 源文件.go"
    echo "例如: ./build_template.sh myapp main.go"
    echo "      ./build_template.sh demo demo.go"
    echo ""
    echo "创建示例: ./build_template.sh demo"
fi 