#include <Python.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "python_wrapper.h"

static PyObject *pModule = NULL;
static PyObject *pFunc = NULL;
static PyObject *pOcrInstance = NULL;

void init_python() {
    Py_Initialize();
    PyRun_SimpleString("import sys");
    PyRun_SimpleString("sys.path.append('python')");
    
    pModule = PyImport_ImportModule("script");
    if (pModule == NULL) {
        PyErr_Print();
        return;
    }
    
    // 初始化 OCR 实例
    PyObject *pInitFunc = PyObject_GetAttrString(pModule, "init_ocr");
    if (pInitFunc && PyCallable_Check(pInitFunc)) {
        pOcrInstance = PyObject_CallObject(pInitFunc, NULL);
        Py_DECREF(pInitFunc);
    }
}

const char* recognize_captcha(const char* image_data) {
    if (!pModule || !pOcrInstance) {
        return "Error: Python module or OCR instance not initialized";
    }
    
    PyObject *pFunc = PyObject_GetAttrString(pModule, "recognize_captcha");
    if (pFunc && PyCallable_Check(pFunc)) {
        PyObject *pArgs = PyTuple_New(2);
        PyTuple_SetItem(pArgs, 0, pOcrInstance);
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
    if (pOcrInstance) {
        Py_DECREF(pOcrInstance);
    }
    if (pModule) {
        Py_DECREF(pModule);
    }
    Py_Finalize();
} 