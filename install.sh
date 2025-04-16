#!/bin/bash

# 安装脚本 - 配置captchaocr依赖库的环境

# 设置颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}开始安装 CaptchaOCR 依赖...${NC}"

# 清除旧的构建缓存
echo "清除旧的构建缓存..."
rm -rf build
find . -name "__pycache__" -type d -exec rm -rf {} 2>/dev/null \; || true
find . -name "*.pyc" -delete

# 创建必要的目录
mkdir -p build

# 安装 Python 依赖
echo "安装 Python 依赖..."
pip3 install -r pkg/python/requirements.txt

# 获取 Python 版本和路径
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
PYTHON_PATH=$(python3 -c "import sys; print(sys.prefix)")
CURRENT_DIR="$PWD"

# 编译 C 代码
echo "编译 Python Wrapper..."
gcc -c pkg/python/wrapper/python_wrapper.c -o build/python_wrapper.o $(python3-config --includes)

# 检查编译结果
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Python Wrapper 编译成功！${NC}"
else
    echo -e "${RED}Python Wrapper 编译失败，请检查错误信息${NC}"
    exit 1
fi

# 创建用于编译项目的脚本
BUILD_SCRIPT="build/build.sh"
echo "#!/bin/bash" > $BUILD_SCRIPT
echo "" >> $BUILD_SCRIPT
echo "# CaptchaOCR 项目编译脚本" >> $BUILD_SCRIPT
echo "# 由 install.sh 自动生成" >> $BUILD_SCRIPT
echo "" >> $BUILD_SCRIPT
echo "# 设置 Python 环境变量" >> $BUILD_SCRIPT
echo "export CGO_CFLAGS=\"-I${PYTHON_PATH}/include/python${PYTHON_VERSION}\"" >> $BUILD_SCRIPT
echo "export CGO_LDFLAGS=\"-L${PYTHON_PATH}/lib -lpython${PYTHON_VERSION} -Wl,-force_load,${CURRENT_DIR}/build/python_wrapper.o,-no_warn_duplicate_libraries\"" >> $BUILD_SCRIPT
echo "" >> $BUILD_SCRIPT
echo "# 编译你的项目" >> $BUILD_SCRIPT
echo 'echo "编译你的项目..."' >> $BUILD_SCRIPT
echo 'go build "$@"' >> $BUILD_SCRIPT

chmod +x $BUILD_SCRIPT

echo -e "${GREEN}安装完成！${NC}"
echo -e "${BLUE}使用说明:${NC}"
echo "1. 在你的项目中导入 captchaocr 包:"
echo "   import \"captchaocr\""
echo ""
echo "2. 使用 ${CURRENT_DIR}/build/build.sh 编译你的项目:"
echo "   ${CURRENT_DIR}/build/build.sh -o yourapp"
echo ""
echo "3. 示例代码可以参考 examples/main.go" 