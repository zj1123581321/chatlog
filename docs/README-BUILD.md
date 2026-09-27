# Chatlog 构建和运行指南

## 🚨 CGO 问题修复

如果你遇到以下错误：
```
Binary was compiled with 'CGO_ENABLED=0', go-sqlite3 requires cgo to work. This is a stub
```

这表示 SQLite 驱动需要 CGO 支持，但程序在编译时禁用了 CGO。

## 🔧 快速修复方案

### Windows 用户

#### 方案一：使用自动化脚本（推荐）

1. **检查环境**
   ```cmd
   check-env.bat
   ```

2. **构建程序**
   ```cmd
   build.bat
   ```

3. **启动服务器**
   ```cmd
   start-server.bat
   ```

#### 方案二：手动修复

1. **安装 C 编译器**
   
   选择以下任一方式：
   
   **选项 A: TDM-GCC (推荐)**
   - 下载：https://jmeubank.github.io/tdm-gcc/download/
   - 安装后重启命令提示符
   
   **选项 B: MinGW-w64**
   - 下载：https://www.mingw-w64.org/downloads/
   - 添加到 PATH 环境变量
   
   **选项 C: Visual Studio Build Tools**
   - 下载：https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022
   - 安装 C++ 构建工具

2. **设置环境变量并构建**
   ```cmd
   set CGO_ENABLED=1
   go build -o chatlog.exe main.go
   ```

3. **运行服务器**
   ```cmd
   chatlog.exe server --addr "<host>:5030" --data-dir "<wechat-data-dir>" --work-dir "<work-dir>" --platform windows --version 3 --data-key "<your-data-key>" --auto-decrypt
   ```

### Linux/macOS 用户

1. **运行构建脚本**
   ```bash
   ./build.sh
   ```

2. **手动构建（如果需要）**
   ```bash
   # 安装编译器
   # Ubuntu/Debian: sudo apt-get install build-essential
   # CentOS/RHEL: sudo yum groupinstall 'Development Tools'
   # macOS: xcode-select --install
   
   # 构建
   export CGO_ENABLED=1
   go build -o chatlog main.go
   
   # 运行
   ./chatlog server [参数...]
   ```

## 📋 环境要求

### 必需软件
- **Go 1.24.0+** - Go 编程语言
- **C 编译器** - 用于 CGO 支持
  - Windows: GCC (TDM-GCC/MinGW-w64) 或 Visual Studio
  - Linux: GCC 或 Clang
  - macOS: Xcode Command Line Tools

### 可选工具
- **Make** - 构建自动化 (可选)
- **UPX** - 二进制文件压缩 (可选)

## 🎯 构建选项

### 标准构建
```bash
# Windows
build.bat

# Linux/macOS
./build.sh
```

### 使用 Makefile
```bash
# 完整构建流程
make all

# 仅构建
make build

# 交叉编译
make crossbuild
```

### 手动构建
```bash
# 设置 CGO
export CGO_ENABLED=1  # Linux/macOS
set CGO_ENABLED=1     # Windows

# 基础构建
go build -o chatlog main.go

# 优化构建
go build -ldflags "-s -w" -o chatlog main.go

# 带版本信息
go build -ldflags "-s -w -X 'github.com/sjzar/chatlog/pkg/version.Version=v1.0.0'" -o chatlog main.go
```

## 🚀 运行服务器

### 使用构建好的二进制文件

```bash
# Windows
bin\chatlog.exe server [参数...]

# Linux/macOS  
./bin/chatlog server [参数...]
```

### 直接使用 go run (需要 CGO)

```bash
# Windows
set CGO_ENABLED=1
go run main.go server [参数...]

# Linux/macOS
CGO_ENABLED=1 go run main.go server [参数...]
```

### 完整启动示例

```bash
chatlog server \
  --addr "<host>:5030" \
  --data-dir "<wechat-data-dir>" \
  --work-dir "<work-dir>" \
  --platform windows \
  --version 3 \
  --data-key "<your-data-key>" \
  --auto-decrypt
```

## 🔍 故障排除

### 常见错误及解决方案

#### 1. CGO 相关错误
```
Binary was compiled with 'CGO_ENABLED=0', go-sqlite3 requires cgo to work
```
**解决方案**: 安装 C 编译器，设置 `CGO_ENABLED=1` 后重新构建

#### 2. 编译器未找到
```
exec: "gcc": executable file not found in %PATH%
```
**解决方案**: 安装 GCC 或其他 C 编译器，确保在 PATH 中

#### 3. 链接错误
```
undefined reference to `XXX`
```
**解决方案**: 确保所有依赖都正确安装，尝试 `go mod tidy`

#### 4. 权限错误
```
access denied / permission denied
```
**解决方案**: 以管理员权限运行，或检查文件权限

## 📊 构建验证

构建完成后可以验证：

```bash
# 检查版本
chatlog version

# 检查帮助
chatlog --help

# 测试服务器启动
chatlog server --help
```

## 🎛️ 环境变量

常用的环境变量设置：

```bash
# 启用 CGO
export CGO_ENABLED=1

# 指定编译器
export CC=gcc

# Go 相关
export GOOS=windows
export GOARCH=amd64

# 构建标志
export LDFLAGS="-s -w"
```

## 📦 预编译版本

如果构建遇到困难，可以：

1. 下载官方预编译版本：https://github.com/sjzar/chatlog/releases
2. 预编译版本已经启用 CGO 支持
3. 下载后直接解压使用

## 🤝 获取帮助

如果仍然遇到问题：

1. 运行 `check-env.bat` 检查环境
2. 查看详细错误信息
3. 提交 Issue 到 GitHub
4. 在 Discussions 中寻求帮助

## 📝 开发构建

开发者额外选项：

```bash
# 开启调试信息
go build -gcflags="all=-N -l" -o chatlog main.go

# 启用竞态检测
go build -race -o chatlog main.go

# 生成覆盖率报告
go test -cover ./...
```