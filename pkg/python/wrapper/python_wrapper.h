#ifndef PYTHON_WRAPPER_H
#define PYTHON_WRAPPER_H

#include <Python.h>

// 初始化 Python 解释器
void init_python();

// 识别验证码
const char* recognize_captcha(const char* image_data);

#endif 