#ifndef PYTHON_WRAPPER_H
#define PYTHON_WRAPPER_H

#include <Python.h>

// 初始化 Python 解释器
void init_python();

// 清理 Python 解释器
void cleanup_python();

// 调用 Python 函数
int call_python_add(int a, int b);

#endif 