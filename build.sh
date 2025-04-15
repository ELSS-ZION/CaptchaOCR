#!/bin/bash

# 获取 Python 版本和路径
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
PYTHON_PATH=$(python3 -c "import sys; print(sys.prefix)")

# 设置环境变量
export CGO_CFLAGS="-I${PYTHON_PATH}/include/python${PYTHON_VERSION}"
export CGO_LDFLAGS="-L${PYTHON_PATH}/lib -lpython${PYTHON_VERSION}"

# 编译项目
echo "正在编译项目..."
go build -o golang_cgo_python

# 检查编译结果
if [ $? -eq 0 ]; then
    echo "编译成功！"
    echo "运行程序：./golang_cgo_python"
else
    echo "编译失败，请检查错误信息"
fi 