#!/bin/bash

# CaptchaOCR 项目构建脚本
# 此脚本用于编译使用CaptchaOCR的项目
# 可以直接复制到自己的项目目录中使用

# 找到库的安装位置（简化版本，避免复杂的管道和引号问题）
GO_MOD_PATH=$(go env GOMODCACHE)
if [ -z "$GO_MOD_PATH" ]; then
    # 对于旧版本go，尝试使用GOPATH
    GO_MOD_PATH="$GOPATH/pkg/mod"
    if [ -z "$GO_MOD_PATH" ]; then
        echo "错误: 找不到Go模块缓存路径，请先设置GOPATH环境变量"
        exit 1
    fi
fi

# 从下到上搜索具体版本目录
CAPTCHAOCR_PATH=$(find "$GO_MOD_PATH" -type d -name "github.com!e!l!s!s*!z!i!o!n!*!captcha!o!c!r*" | sort -r | head -n 1)
if [ -z "$CAPTCHAOCR_PATH" ]; then
    echo "错误: 找不到 CaptchaOCR 模块，请先安装: go get github.com/ELSS-ZION/CaptchaOCR@v0.3.2"
    exit 1
fi

echo "CaptchaOCR 目录: $CAPTCHAOCR_PATH"

# 检查是否存在 python_wrapper.o
if [ ! -f "$CAPTCHAOCR_PATH/build/python_wrapper.o" ]; then
    echo "编译 C 代码..."
    mkdir -p "$CAPTCHAOCR_PATH/build"
    
    # 检查是否有权限写入
    if [ ! -w "$CAPTCHAOCR_PATH/build" ]; then
        echo "警告: 没有写入权限到 $CAPTCHAOCR_PATH/build"
        echo "将在当前目录创建 build 目录"
        mkdir -p "./build"
        WRAPPER_OUTPUT="./build/python_wrapper.o"
    else
        WRAPPER_OUTPUT="$CAPTCHAOCR_PATH/build/python_wrapper.o"
    fi
    
    # 编译C代码
    gcc -c "$CAPTCHAOCR_PATH/pkg/captchaocr/wrapper/python_wrapper.c" -o "$WRAPPER_OUTPUT" $(python3-config --includes)
    
    if [ $? -ne 0 ]; then
        echo "错误: C 代码编译失败"
        exit 1
    fi
else
    WRAPPER_OUTPUT="$CAPTCHAOCR_PATH/build/python_wrapper.o"
fi

# 获取Python信息
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
PYTHON_PATH=$(python3 -c "import sys; print(sys.prefix)")

# 安装 Python 依赖
echo "安装 Python 依赖..."
pip3 install -r "$CAPTCHAOCR_PATH/pkg/captchaocr/python/requirements.txt"

# 设置编译环境变量
export CGO_CFLAGS="-I${PYTHON_PATH}/include/python${PYTHON_VERSION}"
export CGO_LDFLAGS="-L${PYTHON_PATH}/lib -lpython${PYTHON_VERSION} -Wl,-force_load,${WRAPPER_OUTPUT},-no_warn_duplicate_libraries"

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
    echo "用法: ./project_build.sh 输出文件名 main.go"
    echo "例如: ./project_build.sh myapp main.go"
fi 