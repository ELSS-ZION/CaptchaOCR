#include <Python.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "python_wrapper.h"

static PyObject *pOcrInstance = NULL;

// 嵌入Python代码
const char* EMBEDDED_PYTHON_CODE = 
"import ddddocr\n"
"import base64\n"
"from io import BytesIO\n"
"\n"
"def init_ocr():\n"
"    return ddddocr.DdddOcr(show_ad=False)\n"
"\n"
"def recognize_captcha(ocr_instance, image_data):\n"
"    try:\n"
"        # 将 base64 图片数据转换为字节\n"
"        image_bytes = base64.b64decode(image_data)\n"
"        # 创建 BytesIO 对象\n"
"        image_stream = BytesIO(image_bytes)\n"
"        # 识别验证码\n"
"        result = ocr_instance.classification(image_stream.read())\n"
"        return result\n"
"    except Exception as e:\n"
"        return f\"Error: {str(e)}\"\n";

void init_python() {
    Py_Initialize();
    
    // 创建主模块
    PyObject *pMainModule = PyImport_AddModule("__main__");
    PyObject *pMainDict = PyModule_GetDict(pMainModule);
    
    // 执行嵌入式Python代码
    PyObject *pResult = PyRun_String(EMBEDDED_PYTHON_CODE, Py_file_input, pMainDict, pMainDict);
    if (!pResult) {
        PyErr_Print();
        return;
    }
    Py_DECREF(pResult);
    
    // 获取init_ocr函数
    PyObject *pInitFunc = PyDict_GetItemString(pMainDict, "init_ocr");
    if (pInitFunc && PyCallable_Check(pInitFunc)) {
        pOcrInstance = PyObject_CallObject(pInitFunc, NULL);
    } else {
        PyErr_Print();
    }
}

const char* recognize_captcha(const char* image_data) {
    if (!pOcrInstance) {
        return "Error: OCR instance not initialized";
    }
    
    // 创建主模块的字典
    PyObject *pMainModule = PyImport_AddModule("__main__");
    PyObject *pMainDict = PyModule_GetDict(pMainModule);
    
    // 获取recognize_captcha函数
    PyObject *pFunc = PyDict_GetItemString(pMainDict, "recognize_captcha");
    if (pFunc && PyCallable_Check(pFunc)) {
        PyObject *pArgs = PyTuple_New(2);
        Py_INCREF(pOcrInstance); // 增加引用计数，因为PyTuple_SetItem会窃取引用
        PyTuple_SetItem(pArgs, 0, pOcrInstance);
        PyTuple_SetItem(pArgs, 1, PyUnicode_FromString(image_data));
        
        PyObject *pResult = PyObject_CallObject(pFunc, pArgs);
        Py_DECREF(pArgs);
        
        if (pResult != NULL) {
            const char* result = PyUnicode_AsUTF8(pResult);
            char* return_value = strdup(result);
            Py_DECREF(pResult);
            return return_value;
        } else {
            PyErr_Print();
        }
    }
    
    return "Error: Failed to recognize captcha";
}

void cleanup_python() {
    if (pOcrInstance) {
        Py_DECREF(pOcrInstance);
        pOcrInstance = NULL;
    }
    Py_Finalize();
} 