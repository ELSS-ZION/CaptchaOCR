#!/bin/bash

# 安装 Python 依赖
pip3 install -r requirements.txt

# 获取 Python 版本和路径
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
PYTHON_PATH=$(python3 -c "import sys; print(sys.prefix)")
CURRENT_DIR="$PWD"

# 设置环境变量
export CGO_CFLAGS="-I${PYTHON_PATH}/include/python${PYTHON_VERSION}"
export CGO_LDFLAGS="-L${PYTHON_PATH}/lib -lpython${PYTHON_VERSION} -Wl,-force_load,${CURRENT_DIR}/python_wrapper.o,-no_warn_duplicate_libraries"

# 编译 C 代码
gcc -c python/wrapper/python_wrapper.c -o python_wrapper.o $(python3-config --includes)

# 编译 Go 代码
go build -o golang_cgo_python

# 检查编译结果
if [ $? -eq 0 ]; then
    echo "编译成功！"
    echo "运行程序：./golang_cgo_python"
else
    echo "编译失败，请检查错误信息"
fi 