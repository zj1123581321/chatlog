#!/bin/bash
: "${CHATLOG_DATA_KEY:?CHATLOG_DATA_KEY must be set}"

echo "==========================================="
echo "  Chatlog Linux/macOS 构建脚本"
echo "==========================================="

# 检查 Go 是否安装
if ! command -v go &> /dev/null; then
    echo "❌ 错误: 找不到 Go 编译器"
    echo "   请安装 Go: https://golang.org/dl/"
    exit 1
fi

# 显示 Go 版本
echo "✅ Go 版本:"
go version

# 检查编译器
echo ""
echo "🔍 检查 C 编译器..."
if command -v gcc &> /dev/null; then
    echo "✅ 找到 GCC 编译器"
    gcc --version | head -1
elif command -v clang &> /dev/null; then
    echo "✅ 找到 Clang 编译器"
    clang --version | head -1
    export CC=clang
else
    echo "❌ 错误: 找不到 C 编译器 (gcc 或 clang)"
    echo ""
    echo "请安装编译器:"
    
    # 检测系统并给出安装建议
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "  Ubuntu/Debian: sudo apt-get install build-essential"
        echo "  CentOS/RHEL: sudo yum groupinstall 'Development Tools'"
        echo "  Fedora: sudo dnf groupinstall 'Development Tools'"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  macOS: xcode-select --install"
        echo "  或安装 Homebrew: brew install gcc"
    fi
    
    exit 1
fi

# 设置构建环境
echo ""
echo "🔧 设置构建环境..."
export CGO_ENABLED=1

# 检测系统架构
GOOS=$(go env GOOS)
GOARCH=$(go env GOARCH)

echo "   CGO_ENABLED=1"
echo "   GOOS=$GOOS"
echo "   GOARCH=$GOARCH"

# 清理旧的构建文件
echo ""
echo "🧹 清理旧的构建文件..."
rm -f chatlog
rm -rf bin/

# 创建 bin 目录
mkdir -p bin

# 构建项目
echo ""
echo "🔨 开始构建 Chatlog..."

if go build -ldflags "-s -w" -o bin/chatlog main.go; then
    echo "✅ 构建成功!"
    echo "   输出文件: bin/chatlog"
    
    # 显示文件信息
    if command -v ls &> /dev/null; then
        echo "   文件信息: $(ls -lh bin/chatlog | awk '{print $5, $9}')"
    fi
    
    # 设置执行权限
    chmod +x bin/chatlog
    
    # 测试版本命令
    echo ""
    echo "🧪 测试构建结果..."
    if bin/chatlog version; then
        echo "✅ 版本命令执行成功"
    else
        echo "⚠️  警告: 版本命令执行失败"
    fi
    
    echo ""
    echo "🚀 构建完成! 你现在可以使用以下命令启动服务器:"
    echo ""
    echo './bin/chatlog server --addr "<host>:5030" \'
    echo '  --data-dir "$HOME/WeChatData" \'
    echo '  --work-dir "$HOME/chatlog-work" \'
    echo '  --platform windows --version 3 \'
    echo '  --data-key "${CHATLOG_DATA_KEY:?CHATLOG_DATA_KEY must be set}" \'
    echo '  --auto-decrypt'
    echo ""
    
else
    echo "❌ 构建失败!"
    echo ""
    echo "常见问题解决:"
    echo "  1. 确保安装了 C 编译器 (gcc 或 clang)"
    echo "  2. 检查 PATH 环境变量是否包含编译器路径"
    echo "  3. 尝试运行: go mod tidy"
    echo "  4. 检查 CGO_ENABLED 是否设置为 1"
    echo ""
    exit 1
fi