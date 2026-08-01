# Android Platform Tools (ADB / Fastboot) 配置指南

在 Fedora 系统上，调试 Android 设备、刷机固件或进行无线调试时，需要使用 Android Platform Tools 工具包（主要包含 `adb` Android 调试桥与 `fastboot` 引导程序工具）。Fedora 官方 DNF 仓库直接提供了包含全套原生二进制工具的 `android-tools` 软件包。

---

## 1. 安装 android-tools 软件包

无需手动下载 Android SDK 解压与配置 `$PATH` 环境变量，直接通过 DNF 一键安装官方编译的 `android-tools`：

```bash
sudo dnf install -y android-tools
```

### 包含的主要核心工具：
- **`adb`**: Android Debug Bridge (用于命令行管理手机、文件传输、应用安装与无线调试)。
- **`fastboot`**: 用于在 Bootloader / Fastboot 模式下刷写分区镜像与解锁引导加载程序。
- **`mke2fs.android` / `e2fsdroid`**: Android 专用扩展文件系统构建工具。

---

## 2. 验证 ADB 安装与版本查看

安装完成后，可以在终端中直接调用全局可执行文件 `/usr/bin/adb`：

```bash
adb version
```

**预期输出示例**：
```text
Android Debug Bridge version 1.0.41
Version 35.0.2-android-tools
Installed as /usr/bin/adb
Running on Linux 7.1.5-201.fc44.x86_64 (x86_64)
```

---

## 3. ADB 常用实践命令速查

### 3.1 设备连接与状态列出
```bash
# 列出当前已连接的 USB/无线 Android 设备
adb devices -l

# 重启 ADB 后台守护进程
adb kill-server
adb start-server
```

### 3.2 无线调试 (Android 11+)
```bash
# 1. 首次配对（在手机开发者选项 - 无线调试中查看配对码与端口）
adb pair <IP>:<PORT> <PAIRING_CODE>

# 2. 连接无线调试设备
adb connect <IP>:<PORT>

# 3. 断开连接
adb disconnect <IP>:<PORT>
```

### 3.3 应用安装与卸载
```bash
# 安装 APK (覆盖安装 -r，赋予运行时权限 -g)
adb install -r -g /path/to/app.apk

# 卸载应用 (保留应用数据 -k)
adb uninstall -k com.example.app
```

### 3.4 文件传输 (Push & Pull)
```bash
# 将电脑本地文件推送到手机
adb push ~/Downloads/test.apk /sdcard/Download/

# 从手机拉取文件到电脑本地
adb pull /sdcard/Download/photo.jpg ~/Pictures/
```

### 3.5 交互式 Shell 与日志
```bash
# 进入手机内部 Linux 命令行界面
adb shell

# 查看设备实时日志 (Logcat)
adb logcat
```

---

## 4. 常见踩坑：USB 调试权限排查 (no permissions / unauthorized)

在 Linux 环境下通过 USB 数据线连接手机时，如果运行 `adb devices` 提示 `no permissions` 或 `unauthorized`，排查与解决步骤如下：

### 4.1 确认手机端授权弹窗
首次连接 USB 调试时，手机屏幕会弹出 **“是否允许这台计算机进行 USB 调试？”** 询问提示框。请勾选 **“总是允许来自这台计算机的调试”** 并点击确定。

### 4.2 将当前用户加入 `adbusers` 用户组
Fedora 系统默认会自动创建 `adbusers` 用户组：

```bash
# 将当前用户加入 adbusers 组
sudo usermod -aG adbusers $USER

# 重启 adb 守护进程生效
adb kill-server
adb start-server
```

> **提示**: 添加用户组后可能需要注销当前桌面会话或重新登录终端以使组权限完全生效。

### 4.3 (可选) 手动配置 /etc/udev/rules.d/51-android.rules
若少数小众品牌手机仍然无法识别 USB 权限，可手动创建配置文件放行 USB 设备：

```bash
sudo tee /etc/udev/rules.d/51-android.rules <<'EOF'
# 全局 Android USB 调试放行规则
SUBSYSTEM=="usb", MODE="0666", GROUP="adbusers"
EOF

# 重新加载 udev 规则
sudo udevadm control --reload-rules
sudo udevadm trigger
```
