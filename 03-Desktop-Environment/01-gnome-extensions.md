# GNOME 核心扩展与界面美化 (UI 调优篇)

Fedora Workstation 默认搭载的 GNOME 桌面环境较为原生（俗称“毛坯房”），缺乏常驻 Dock 栏以及窗口右上角的“最小化/最大化”控制按钮。本篇记录如何通过官方扩展与配置提升使用体验。

---

## 0. 前置准备：开启 Web 浏览器一键安装 GNOME 扩展能力

在 GNOME 官方扩展商店 ([extensions.gnome.org](https://extensions.gnome.org/)) 中，可以直接在网页中点击“开关”按钮一键为系统下载并安装任意 GNOME 扩展。

实现该功能需要两步配合：

### 0.1 安装系统底层通信连接器 (gnome-browser-connector)
在 Fedora 中运行以下命令安装原生通信桥梁包：

```bash
sudo dnf install -y gnome-browser-connector
```
*(注: `gnome-browser-connector` 为 Fedora 官方现代化包名，兼容并替代了旧版的 `chrome-gnome-shell`)*

### 0.2 安装浏览器对应扩展插件

打开浏览器对应的扩展商店，安装 **`GNOME Shell integration`** 插件：

- **方法一（推荐直接搜索，最稳定）**:
  在 Google Chrome / Microsoft Edge 的 **Chrome 网上应用店** 或 **Edge 扩展商店** 中，直接搜索关键字：`GNOME Shell integration`，选择由 *gnome.org* 官方提供的扩展点击安装。

- **方法二（直接访问扩展页面）**:
  - **Chrome / Edge (Chrome Web Store)**: [GNOME Shell 集成直达链接](https://chromewebstore.google.com/detail/gnome-shell-%E9%9B%86%E6%88%90/gphhapmejobijbbhgpjhcjognlahblep)

  - **Mozilla Firefox (Firefox Add-ons)**: [GNOME Shell integration (Firefox 附加组件)](https://addons.mozilla.org/zh-CN/firefox/addon/gnome-shell-integration/)

安装完成后，刷新或重新打开 [extensions.gnome.org](https://extensions.gnome.org/) 网页，即可在网页上方看到“已启用 GNOME Shell 扩展集成”，随后直接点击网页上的开关即可一键安装、更新和管理系统扩展。


---

## 1. Dash to Dock 扩展安装与图形管理工具

通过 DNF 安装官方源中的 `Dash to Dock` 扩展以及 GNOME 扩展管理应用：

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

### 方案 A：macOS 风格（悬浮 / 常驻 Dock 栏）
1. 在设置中选择 **位置和大小 (Position and size)** 选项卡。
2. 取消勾选 **智能隐藏 (Intelligent autohide)**。
3. **效果**: Dock 栏将始终保持在桌面底部常驻，不随窗口遮挡而自动隐藏，获得类似 macOS 的高效率操作体验。

### 方案 B：Ubuntu 风格（通栏长 Dock 栏）
1. 在选择常驻的基础上，在 **位置和大小 (Position and size)** 选项卡中。
2. 开启 **面板模式：延伸到屏幕边缘 (Panel mode: extend to the screen edge)**。
3. **效果**: Dock 栏背景将横向拉伸覆盖整个屏幕底部边缘，实现类似 Ubuntu 默认的全局 Bottom Panel 风格。

---

## 3. 开启窗口右上角“最小化”与“最大化”按钮

GNOME 默认标题栏只有“关闭”按钮。可以通过官方“优化” (GNOME Tweaks) 工具恢复传统的最小化与最大化功能。

### 终端命令安装 GNOME Tweaks
```bash
sudo dnf install -y gnome-tweaks
```

### 图形界面设置步骤
1. 安装完成后，在应用程序列表中打开名为 **“优化” (Tweaks)** 的应用。
2. 在左侧边栏中选择 **窗口 (Windows / Window Titlebars)** 选项卡。
3. 找到 **标题栏按钮 (Titlebar Buttons)** 部分。
4. 勾选开启 **最小化 (Minimize)** 与 **最大化 (Maximize)** 开关。
5. **放置 (Placement)** 保持选择 **右边 (Right)**（窗口右上角）。

### 命令行一键启用方案 (gsettings)
如需在 Shell 脚本中免 GUI 自动化开启，直接运行以下命令即可：

```bash
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
```

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

---

## 5. 类 Ubuntu 桌面快捷方式与文件夹支持 (GTK4 Desktop Icons NG / DING)

GNOME 原生桌面禁用了桌面放置图标和文件夹的功能。通过安装 DING (Desktop Icons NG) 扩展，可以恢复类似 Ubuntu / Windows 的桌面文件管理体验。

- **扩展商店安装页面**: [GTK4 Desktop Icons NG (DING)](https://extensions.gnome.org/extension/5263/gtk4-desktop-icons-ng-ding/)

### 安装与功能特色
1. 完成 [0. 前置准备] 后，直接在浏览器中打开上述拓展页面，将页面右上角的 **OFF** 开关切换为 **ON**，在弹出的系统对话框中点击 **安装 (Install)** 即可。
2. **核心体验**:
   - 支持将各种文件、文件夹直接拖拽放置到桌面上显示。
   - 支持在桌面上创建应用程序快捷方式图标 (`.desktop` 文件)。
   - 桌面右键菜单提供“新建文件夹”、“按名称/时间排序图标”等完整操作。

---

## 6. 高高级感的顶栏与 Dock 栏半透明毛玻璃美化 (Blur my Shell)

Blur my Shell 是 GNOME 生态中最受欢迎的美化扩展之一，能为顶栏、Dash to Dock 栏以及应用网关背景添加逼真的半透明高斯模糊毛玻璃效果 (Glassmorphism Effect)。

- **扩展商店安装页面**: [Blur my Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/)

### 安装与效果微调
1. 直接在浏览器打开上述扩展页面，切换开关为 **ON** 并点击 **安装**。
2. 打开 **“扩展” (Extensions)** 应用，找到 **Blur my Shell** 并点击旁边的“设置”选项：
   - **Top Panel (顶栏)**: 开启顶部状态栏毛玻璃效果，提供实时背景动态高斯模糊。
   - **Dash to Dock (Dock 栏)**: 将底部的 Dash to Dock 栏背景替换为通透的磨砂玻璃材质。
   - **Overview (应用网关)**: 调整按下 `Super` 键进入应用网关时的背景深浅与模糊半径。




