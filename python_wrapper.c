#include "python_wrapper.h"
#include <stdio.h>

static PyObject *pModule;
static PyObject *pFunc;

void init_python() {
    Py_Initialize();
    
    // 添加当前目录到 Python 路径
    PyRun_SimpleString("import sys\n"
                      "sys.path.append('.')\n");
    
    // 导入 Python 模块
    pModule = PyImport_ImportModule("script");
    if (!pModule) {
        PyErr_Print();
        return;
    }
    
    // 获取函数对象
    pFunc = PyObject_GetAttrString(pModule, "add_numbers");
    if (!pFunc) {
        PyErr_Print();
        return;
    }
}

void cleanup_python() {
    Py_XDECREF(pFunc);
    Py_XDECREF(pModule);
    Py_Finalize();
}

int call_python_add(int a, int b) {
    PyObject *pArgs, *pValue;
    int result = 0;
    
    // 创建参数元组
    pArgs = PyTuple_New(2);
    PyTuple_SetItem(pArgs, 0, PyLong_FromLong(a));
    PyTuple_SetItem(pArgs, 1, PyLong_FromLong(b));
    
    // 调用函数
    pValue = PyObject_CallObject(pFunc, pArgs);
    Py_DECREF(pArgs);
    
    if (pValue != NULL) {
        result = PyLong_AsLong(pValue);
        Py_DECREF(pValue);
    } else {
        PyErr_Print();
    }
    
    return result;
} 