# GNOME 核心扩展与界面美化 (UI 调优篇)

Fedora Workstation 默认搭载的 GNOME 桌面环境较为原生（俗称“毛坯房”），缺乏常驻 Dock 栏以及窗口右上角的“最小化/最大化”控制按钮。本篇记录如何通过官方扩展与配置提升使用体验。

---

## 1. Dash to Dock 扩展安装与图形管理工具

首先通过 DNF 安装官方源中的 `Dash to Dock` 扩展以及 GNOME 扩展管理应用：

### 终端命令
```bash
sudo dnf install -y gnome-shell-extension-dash-to-dock gnome-extensions-app
```

- **`gnome-shell-extension-dash-to-dock`**: Dash to Dock 原生 RPM 扩展包。
- **`gnome-extensions-app`**: 官方独立的“扩展” (Extensions) 图形化管理工具，方便随时开启/关闭及配置扩展。

---

## 2. 启用与个性化 Dock 栏配置

安装完成后，在应用列表中打开 **“扩展” (Extensions)** 应用，找到并开启 **Dash to Dock**。

点击 Dash to Dock 旁边的“设置”图标，进行如下个性化微调：

### 🍎 方案 A：macOS 风格（悬浮 / 常驻 Dock 栏）
1. 在设置中选择 **位置和大小 (Position and size)** 选项卡。
2. 取消勾选 **智能隐藏 (Intelligent autohide)**。
3. **效果**: Dock 栏将始终保持在桌面底部常驻，不随窗口遮挡而自动隐藏，获得类似 macOS 的高效率操作体验。

### 🐧 方案 B：Ubuntu 风格（通栏长 Dock 栏）
1. 在选择常驻的基础上，在 **位置和大小 (Position and size)** 选项卡中。
2. 开启 **面板模式：延伸到屏幕边缘 (Panel mode: extend to the screen edge)**。
3. **效果**: Dock 栏背景将横向拉伸覆盖整个屏幕底部边缘，实现类似 Ubuntu 默认的全局 Bottom Panel 风格。

> 💡 **提示**: 完成设置后若扩展未立即加载，可按下 `Alt + F2` 输入 `r` 并回车（X11 环境）或重新登录/重启系统使 GNOME Shell 完全加载新扩展。

---

## 3. 开启窗口右上角“最小化”与“最大化”按钮

GNOME 默认标题栏只有“关闭”按钮。可以通过官方“优化” (GNOME Tweaks) 工具恢复传统的最小化与最大化功能。

### 终端命令安装 GNOME Tweaks
```bash
sudo dnf install -y gnome-tweaks
```

### 🖼️ 图形界面设置步骤
1. 安装完成后，在应用程序列表中打开名为 **“优化” (Tweaks)** 的应用。
2. 在左侧边栏中选择 **窗口 (Windows / Window Titlebars)** 选项卡。
3. 找到 **标题栏按钮 (Titlebar Buttons)** 部分。
4. 勾选开启 **最小化 (Minimize)** 与 **最大化 (Maximize)** 开关。
5. **放置 (Placement)** 保持选择 **右边 (Right)**（窗口右上角）。

### ⚡ 命令行一键启用方案 (gsettings)
如需在 Shell 脚本中免 GUI 自动化开启，直接运行以下命令即可：

```bash
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
```

### 补充：默认窗口快捷键操作提示
即使未开启显示最小化与最大化按钮，也随时可使用系统默认快捷键对当前窗口进行操作：
- **`Super (Windows 键)` + `↓` (下方向键)**: 最小化当前窗口。
- **`Super (Windows 键)` + `↑` (上方向键)**: 最大化当前窗口 / 还原窗口大小。

---

## 4. 恢复 GNOME 桌面右上角系统托盘图标 (AppIndicator Support)

GNOME 默认隐藏了传统后台应用（如微信、QQ、Steam、输入法等）的顶部托盘图标。可以通过开启 AppIndicator 扩展恢复常驻系统托盘。

### 4.1 扩展安装 (若未内置)
```bash
sudo dnf install -y gnome-shell-extension-appindicator
```

### 4.2 图形界面开启与右对齐微调步骤
1. 打开应用程序列表中的 **“扩展” (Extensions)** 应用。
2. 在 **系统扩展 (System Extensions)** 列表中，找到并开启：
   **`AppIndicator and KStatusNotifierItem Support`**
3. 点击该扩展旁边的“设置”按钮进入高级选项：
   - 勾选开启 **启用旧托盘图标支持 (Enable Legacy Tray Icon Support)**（确保老旧应用图标正常显示）。
   - 将 **托盘水平对齐 (Tray Horizontal Alignment)** 选项设置为：**右对齐 (Right)**。

完成设置后，微信、Steam 等后台后台应用在点击关闭后即可在右上角顶栏右侧正常显示托盘小图标。



