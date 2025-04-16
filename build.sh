#!/bin/bash

# CaptchaOCR 构建脚本
# 用于配置和编译使用captchaocr依赖库的项目
# https://github.com/ELSS-ZION/CaptchaOCR

# 设置颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}CaptchaOCR 环境配置和构建工具${NC}"
echo "------------------------------------------------"

# 检查依赖
check_dep() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}错误: 未找到 $1 命令.${NC}"
        echo "请确保已安装 $2"
        exit 1
    fi
}

check_dep "go" "Go (https://golang.org/doc/install)"
check_dep "python3" "Python 3 (https://www.python.org/downloads/)"
check_dep "gcc" "GCC 编译器"
check_dep "pip3" "pip3 (通常随Python3一起安装)"

# 创建工作目录
WORK_DIR="$HOME/.captchaocr"
mkdir -p $WORK_DIR
echo "工作目录: $WORK_DIR"

# 清除旧的构建缓存
echo "清除旧的构建缓存..."
rm -rf $WORK_DIR/build
mkdir -p $WORK_DIR/build

# 安装 Python 依赖
echo "安装 Python 依赖..."
pip3 install ddddocr==1.4.8

# 获取 captchaocr 依赖
echo "检查 captchaocr 依赖..."
go list github.com/ELSS-ZION/CaptchaOCR &> /dev/null

if [ $? -ne 0 ]; then
    echo "正在获取 captchaocr 依赖..."
    go get github.com/ELSS-ZION/CaptchaOCR
    if [ $? -ne 0 ]; then
        echo -e "${RED}获取依赖失败.${NC}"
        exit 1
    fi
fi

# 获取 captchaocr 依赖路径
CAPTCHAOCR_PATH=$(go list -f '{{.Dir}}' github.com/ELSS-ZION/CaptchaOCR)
echo "依赖路径: $CAPTCHAOCR_PATH"

# 检查 wrapper 文件
if [ ! -f "$CAPTCHAOCR_PATH/pkg/python/wrapper/python_wrapper.c" ]; then
    echo -e "${RED}找不到python_wrapper.c文件.${NC}"
    exit 1
fi

# 获取 Python 版本和路径
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
PYTHON_PATH=$(python3 -c "import sys; print(sys.prefix)")

# 编译 C 代码
echo "编译 Python Wrapper..."
gcc -c $CAPTCHAOCR_PATH/pkg/python/wrapper/python_wrapper.c -o $WORK_DIR/build/python_wrapper.o $(python3-config --includes)

# 检查编译结果
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Python Wrapper 编译成功！${NC}"
else
    echo -e "${RED}Python Wrapper 编译失败，请检查错误信息${NC}"
    exit 1
fi

# 设置环境变量
export CGO_CFLAGS="-I${PYTHON_PATH}/include/python${PYTHON_VERSION}"
export CGO_LDFLAGS="-L${PYTHON_PATH}/lib -lpython${PYTHON_VERSION} -Wl,-force_load,${WORK_DIR}/build/python_wrapper.o,-no_warn_duplicate_libraries"

# 编译用户项目
echo -e "${BLUE}编译项目...${NC}"
go build "$@"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}项目编译成功！${NC}"
else
    echo -e "${RED}项目编译失败，请检查错误信息${NC}"
    exit 1
fi

echo -e "${GREEN}完成！${NC}" 