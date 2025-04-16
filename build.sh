#!/bin/bash

# 清除旧的构建和分发目录
echo "清除旧的构建缓存..."
rm -rf build dist

# 清除 Python 缓存
echo "清除 Python 缓存文件..."
find . -name "__pycache__" -type d -exec rm -rf {} 2>/dev/null \; || true
find . -name "*.pyc" -delete

# 创建必要的目录
mkdir -p build dist

# 安装 Python 依赖
pip3 install -r python/requirements.txt

# 获取 Python 版本和路径
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
PYTHON_PATH=$(python3 -c "import sys; print(sys.prefix)")
CURRENT_DIR="$PWD"

# 设置环境变量
export CGO_CFLAGS="-I${PYTHON_PATH}/include/python${PYTHON_VERSION}"
export CGO_LDFLAGS="-L${PYTHON_PATH}/lib -lpython${PYTHON_VERSION} -Wl,-force_load,${CURRENT_DIR}/build/python_wrapper.o,-no_warn_duplicate_libraries"

# 编译 C 代码
gcc -c python/wrapper/python_wrapper.c -o build/python_wrapper.o $(python3-config --includes)

# 编译 Go 代码
go build -o dist/golang_cgo_python

# 检查编译结果
if [ $? -eq 0 ]; then
    echo "编译成功！"
    echo "运行程序：./dist/golang_cgo_python"
else
    echo "编译失败，请检查错误信息"
fi 