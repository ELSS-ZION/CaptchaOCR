#ifndef PYTHON_WRAPPER_H
#define PYTHON_WRAPPER_H

#include <Python.h>

// 初始化 Python 解释器
// python_path 参数用于指定Python脚本的位置
void init_python();

// 清理 Python 解释器
void cleanup_python();

// 识别验证码
const char* recognize_captcha(const char* image_data);

#endif 