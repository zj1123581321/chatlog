@echo off
setlocal enabledelayedexpansion

echo ===========================================
echo   Chatlog Windows 构建脚本
echo ===========================================

:: 检查 Go 是否安装
where go >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 找不到 Go 编译器
    echo    请安装 Go: https://golang.org/dl/
    pause
    exit /b 1
)

:: 显示 Go 版本
echo ✅ Go 版本:
go version

:: 检查 GCC 是否可用
echo.
echo 🔍 检查 C 编译器...
where gcc >nul 2>&1
if errorlevel 1 (
    echo ⚠️  警告: 找不到 GCC 编译器
    echo    正在尝试查找其他编译器...
    
    where cl >nul 2>&1
    if errorlevel 1 (
        echo ❌ 错误: 找不到 C 编译器 (gcc 或 cl.exe)
        echo.
        echo 请安装以下任一编译器:
        echo   1. TDM-GCC: https://jmeubank.github.io/tdm-gcc/
        echo   2. MinGW-w64: https://www.mingw-w64.org/downloads/
        echo   3. Visual Studio Build Tools
        echo.
        pause
        exit /b 1
    ) else (
        echo ✅ 找到 Visual Studio 编译器 (cl.exe)
        set "CC=cl"
    )
) else (
    echo ✅ 找到 GCC 编译器
    gcc --version | findstr gcc
    set "CC=gcc"
)

:: 设置构建环境
echo.
echo 🔧 设置构建环境...
set CGO_ENABLED=1
set GOOS=windows
set GOARCH=amd64

:: 清理旧的构建文件
if exist "chatlog.exe" (
    echo 🧹 清理旧的构建文件...
    del chatlog.exe
)

if exist "bin" (
    rmdir /s /q bin
)

:: 创建 bin 目录
mkdir bin 2>nul

:: 构建项目
echo.
echo 🔨 开始构建 Chatlog...
echo    CGO_ENABLED=1
echo    GOOS=windows
echo    GOARCH=amd64
echo    CC=%CC%

go build -ldflags "-s -w" -o bin\chatlog.exe main.go

if errorlevel 1 (
    echo ❌ 构建失败!
    echo.
    echo 常见问题解决:
    echo   1. 确保安装了 C 编译器 (GCC 或 Visual Studio)
    echo   2. 检查 PATH 环境变量是否包含编译器路径
    echo   3. 尝试运行: go mod tidy
    echo.
    pause
    exit /b 1
)

:: 验证构建结果
if not exist "bin\chatlog.exe" (
    echo ❌ 构建失败: 找不到输出文件
    pause
    exit /b 1
)

echo ✅ 构建成功!
echo    输出文件: bin\chatlog.exe

:: 显示文件信息
for %%F in (bin\chatlog.exe) do (
    echo    文件大小: %%~zF bytes
)

:: 测试版本命令
echo.
echo 🧪 测试构建结果...
bin\chatlog.exe version
if errorlevel 1 (
    echo ⚠️  警告: 版本命令执行失败
) else (
    echo ✅ 版本命令执行成功
)

echo.
echo 🚀 构建完成! 你现在可以使用以下命令启动服务器:
echo.
echo bin\chatlog.exe server --addr "<host>:5030" --data-dir "%USERPROFILE%\Documents\WeChat Files\wxid_example" --work-dir "%USERPROFILE%\chatlog-work" --platform windows --version 3 --data-key "5e13299164a246de8fa36e25c6778ad08623dc9d3e46466999e4da3f8bbbfb5f" --auto-decrypt
echo.

pause