#!/bin/bash

# CaptchaOCR 简易构建脚本
# 这是一个超简单的构建脚本，避免所有路径查找问题
# 只需根据您的系统修改下面的Python路径

# ===== 修改这些变量以匹配您的系统 =====
# Python版本 (例如: 3.8, 3.9, 3.10)
PYTHON_VERSION="3.10"

# Python安装路径 (如果不确定，运行: python3 -c "import sys; print(sys.prefix)")
PYTHON_PATH="/usr/local"
# ===================================

# 检查Python是否正确配置
if ! command -v python3 &> /dev/null; then
    echo "错误: 找不到 python3 命令，请安装Python 3"
    exit 1
fi

# 创建构建目录
mkdir -p build

# 编译C代码
echo "编译 C 代码..."
WRAPPER_SRC=$(find $GOPATH/pkg/mod -name "python_wrapper.c" | grep -i "captchaocr" | head -n 1)

if [ -z "$WRAPPER_SRC" ]; then
    echo "错误: 找不到 python_wrapper.c 文件"
    echo "请先安装: go get github.com/ELSS-ZION/CaptchaOCR@v0.3.2"
    exit 1
fi

echo "找到源文件: $WRAPPER_SRC"
gcc -c "$WRAPPER_SRC" -o "./build/python_wrapper.o" $(python3-config --includes)

if [ $? -ne 0 ]; then
    echo "错误: C 代码编译失败"
    exit 1
fi

# 安装 Python 依赖
REQUIREMENTS=$(find $GOPATH/pkg/mod -name "requirements.txt" | grep -i "captchaocr" | head -n 1)
if [ -z "$REQUIREMENTS" ]; then
    echo "警告: 找不到requirements.txt文件，将跳过Python依赖安装"
else
    echo "安装 Python 依赖: $REQUIREMENTS"
    pip3 install -r "$REQUIREMENTS"
fi

# 设置编译环境变量
export CGO_CFLAGS="-I${PYTHON_PATH}/include/python${PYTHON_VERSION}"
export CGO_LDFLAGS="-L${PYTHON_PATH}/lib -lpython${PYTHON_VERSION} -Wl,-force_load,./build/python_wrapper.o,-no_warn_duplicate_libraries"

# 显示环境设置
echo "设置环境变量:"
echo "CGO_CFLAGS=$CGO_CFLAGS"
echo "CGO_LDFLAGS=$CGO_LDFLAGS"

# 编译项目
if [ "$1" != "" ]; then
    echo "编译项目: $2 -> $1"
    go build -o "$1" "$2"
    
    if [ $? -eq 0 ]; then
        echo "编译成功: $1"
    else
        echo "编译失败"
        exit 1
    fi
else
    echo "用法: ./simple_build.sh 输出文件名 main.go"
    echo "例如: ./simple_build.sh myapp main.go"
fi 