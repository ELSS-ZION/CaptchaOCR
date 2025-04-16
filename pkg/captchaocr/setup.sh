#!/bin/bash

# CaptchaOCR 安装脚本
# 此脚本帮助用户设置必要的环境和依赖

# 获取脚本所在目录的绝对路径
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
MODULE_ROOT=$(dirname $(dirname "$SCRIPT_DIR"))

# 安装 Python 依赖
echo "安装 Python 依赖..."
pip3 install -r "$SCRIPT_DIR/python/requirements.txt"

# 编译 C 代码
echo "编译 Python 包装器..."
mkdir -p "$MODULE_ROOT/build"
gcc -c "$SCRIPT_DIR/wrapper/python_wrapper.c" -o "$MODULE_ROOT/build/python_wrapper.o" $(python3-config --includes)

# 检查编译结果
if [ $? -eq 0 ]; then
    echo "安装成功！"
    echo ""
    echo "在你的项目中使用以下编译标志:"
    echo ""
    
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
    PYTHON_PATH=$(python3 -c "import sys; print(sys.prefix)")
    
    echo "export CGO_CFLAGS=\"-I${PYTHON_PATH}/include/python${PYTHON_VERSION}\""
    echo "export CGO_LDFLAGS=\"-L${PYTHON_PATH}/lib -lpython${PYTHON_VERSION} -Wl,-force_load,${MODULE_ROOT}/build/python_wrapper.o,-no_warn_duplicate_libraries\""
    echo ""
    echo "然后编译你的项目:"
    echo "go build -o yourapp main.go"
else
    echo "安装失败，请检查错误信息"
fi 