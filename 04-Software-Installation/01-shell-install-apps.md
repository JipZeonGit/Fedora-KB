# 常用应用软件与开发工具安装指南

记录通过 DNF、RPM Fusion、COPR 源、官方 RPM 软件包以及便携包安装常用桌面与办公应用（Steam、MPV、VS Code、Microsoft Edge、JetBrains Toolbox、原生微信 Linux 版、WPS Office、WindTerm SSH 终端、星火应用商店）的操作步骤与配置说明。

---

## 1. Steam 游戏客户端安装与优化

Fedora 通过 RPM Fusion Nonfree 仓库提供原生 RPM 格式的 Steam 客户端。

### 1.1 安装 Steam 客户端

在启用 RPM Fusion Nonfree 源的前提下，直接通过 DNF 安装：

```bash
sudo dnf install -y steam
```

#### 📦 系统变化与依赖说明
- **依赖拉取**: Steam 原生版本会引入大量 32 位 (`i686`) 架构的兼容运行库（如 `glibc.i686`, `mesa-dri-drivers.i686`, `mesa-vulkan-drivers.i686`, `alsa-plugins-pulseaudio.i686` 等），以保证老旧 32 位 Windows / Linux 游戏的兼容性。
- **扩展工具**: 自动安装 `steam-devices`，配置针对 Gamepad 游戏手柄 (XBox/DualSense/Pro Controller) 的 `udev` 设备权限规则。

---

### 1.2 切换至 64 位原生客户端 (Steam RT3 实验性客户端)

默认启动的 Steam 客户端为 32 位版本。可以通过启用 Steam Beta 计划并切换到全新的 **Steam RT3 (64-bit)** 客户端来获得更好的性能与内存管理：

#### 🛠️ 操作配置步骤
1. 打开并登录 Steam 客户端。
2. 点击左上角菜单 **Steam** -> **设置 (Settings)**。
3. 进入 **界面 (Interface)** 选项卡。
4. 找到 **参与客户端测试 (Client Beta Participation)**，将其修改为：**`Steam Beta Update`** (加入 Beta 测试)。
5. 滚动到界面设置最下方，勾选启用 **`使用实验性的 Steam RT3 客户端`** (Use experimental Steam RT3 client)。
6. 根据提示点击 **重启 Steam**，客户端重新下载更新后即完成向 64 位架构的切换。

---

### 1.3 补充 32 位 AMD VA-API 硬件解码驱动 (推荐)

某些 32 位旧游戏或包含内嵌 CG 视频动画的游戏在播放视频时，若缺乏 32 位的硬件加速驱动可能会导致播放黑屏或卡顿。建议补充安装 RPM Fusion Freeworld 的 32 位 VA-API 驱动：

```bash
sudo dnf install -y mesa-va-drivers-freeworld.i686
```

- **作用**: 为 32 位环境中的 H.264/HEVC 视频播放提供 AMD GPU 硬件解码加速。

---

### 1.4 常见踩坑：GNOME 窗口标题栏“返祖”与 Gamescope 解决方案

在 Fedora Workstation (GNOME) 环境下运行 Steam Proton 游戏时，窗口化模式经常会出现经典 Windows 98/2000 风格的浅色传统标题栏（即“返祖”标题栏）。

#### 原因分析
GNOME 的 Mutter 合成器在窗口装饰 (Window Decorations) 方面存在兼容性 Bug。Valve 为了避免各种窗口崩溃或异常缩放，在 Proton 中主动禁用了 GNOME 原生窗口装饰，强制回退使用 Wine 自画的经典 Windows 风格标题栏。

#### 解决方案 (按推荐程度排序)

##### 方案一：使用 Gamescope 微合成器 (最推荐)
Gamescope 是 Valve 为 SteamOS 与 Linux 桌面打造的高性能微合成器 (Micro-compositor)，能完全绕过 GNOME Mutter 的窗口装饰 Bug，提供干净的窗口管理、分辨率缩放与全屏控制。

1. **安装 Gamescope**:
   ```bash
   sudo dnf install -y gamescope
   ```

2. **配置 Steam 游戏启动参数**:
   右键点击 Steam 中的游戏 -> **属性 (Properties)** -> **通用 (General)** -> **启动选项 (Launch Options)**，根据需要填写以下参数组合：

   - **推荐默认（显示干净的原生标题栏）**:
     ```bash
     gamescope -- %command%
     ```
     *(不加 `-f` 也不加 `-b` 时，Gamescope 会自动渲染包含“最小化、最大化、关闭”按钮的系统原生标准标题栏，彻底消除浅色返祖框)*

   - **无边框窗口模式 (Borderless Windowed)**:
     ```bash
     gamescope -b -- %command%
     ```
     *(加入 `-b` 参数后隐藏全部标题栏与边框)*

   - **强制全屏模式 (Fullscreen)**:
     ```bash
     gamescope -f -- %command%
     ```
     *(加入 `-f` 参数强制全屏显示)*

   > **分辨率说明**: `-w` (宽度) 与 `-h` (高度) 参数**并非强制输入**。如果不指定 `-w` 与 `-h`，启动后可以直接使用鼠标按住窗口边缘自由拖拽缩放窗口大小；若需要固定窗口比例（如 `1920x1080`），可加上 `gamescope -w 1920 -h 1080 -- %command%`。


##### 方案二：游戏内开启无边框窗口 (Borderless Windowed)
在游戏图形设置中将窗口模式修改为“无边框窗口”，隐藏外部标题栏，获得接近全屏的体验。

##### 方案三：强制使用较旧版本的 Proton
在游戏属性 -> **兼容性** 中强制选择早期版本的 Proton（如 Proton 8 或 Proton 9 早期版本），部分旧版未启用该禁用补丁。

##### 方案四：使用 Proton-GE 社区增强版
通过 ProtonUp-Qt 安装 Proton-GE 补丁版本（特别是开启了原生 Wine-Wayland 支持的版本）。

##### 方案五：等待官方 GNOME 修复
等待 upstream GNOME Mutter 相关修复合并并随 Fedora 更新推送。


---

## 2. MPV 极简高性能媒体播放器

MPV 是 Linux 下最优秀的高性能开源播放器之一，在结合前述安装的完整版 FFmpeg 与 AMD Freeworld 驱动后，可实现完美的 VA-API 硬件解码播放。

### 2.1 安装命令
```bash
sudo dnf install -y mpv
```

### 2.2 搭配生效说明
- 自动调用系统已安装的 `ffmpeg-libs` 与 `mesa-va-drivers-freeworld` 驱动。
- 播放 4K / H.264 / H.265 / VP9 视频时可自动触发 GPU 硬件加速，极大地降低 CPU 占用。

---

## 3. 微软官方软件与工具 (VS Code & Microsoft Edge)

微软官方为 Linux 提供了 RPM 软件仓库，安装前需先导入微软公钥 GPG 密钥。

### 3.1 导入微软官方 GPG 密钥
在终端运行以下命令导入密钥：
```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
```

---

### 3.2 安装 Visual Studio Code (VS Code)

1. **添加 VS Code 官方 RPM 仓库**:
   ```bash
   sudo sh -c 'echo -e "[vscode]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
   ```

2. **刷新 DNF 缓存并安装**:
   ```bash
   sudo dnf check-update
   sudo dnf install -y code
   ```

---

### 3.3 安装 Microsoft Edge 浏览器

合适习惯使用 Edge 的用户，有两种安装方式：

#### 方式一：自动化仓库安装 (推荐)
1. **添加 Edge 官方 RPM 仓库**:
   ```bash
   sudo sh -c 'echo -e "[microsoft-edge]\nname=microsoft-edge\nbaseurl=https://packages.microsoft.com/yumrepos/edge\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/microsoft-edge.repo'
   ```

2. **刷新 DNF 缓存并安装稳定版 Edge**:
   ```bash
   sudo dnf check-update
   sudo dnf install -y microsoft-edge-stable
   ```

#### 方式二：浏览器手动下载单 RPM 包安装
1. 使用自带的 Firefox 浏览器打开微软官方 Edge 仓库路径：
   - 仓库根目录说明: [https://packages.microsoft.com/yumrepos/edge/](https://packages.microsoft.com/yumrepos/edge/)
   - RPM 安装包直接下载目录: [https://packages.microsoft.com/yumrepos/edge/Packages/m/](https://packages.microsoft.com/yumrepos/edge/Packages/m/)
2. 向下滑动页面，选择最新的 `microsoft-edge-stable-*.x86_64.rpm` 软件包点击下载。
3. 下载完成后，在终端直接使用 DNF 安装该 rpm 包（安装后系统也会自动导入官方 repo）：
   ```bash
   sudo dnf install -y ~/Downloads/microsoft-edge-stable-*.rpm
   ```

---

## 4. JetBrains 全家桶与 JetBrains Toolbox 用户级安装指南

推荐使用 **JetBrains Toolbox** 管理及安装 JetBrains 旗下所有 IDE（如 IntelliJ IDEA, PyCharm, CLion, WebStorm, GoLand 等）。

### 4.1 下载与目录准备

1. **下载官方 64 位包**:
   访问 [JetBrains Toolbox 官网](https://www.jetbrains.com/toolbox-app/) 下载 Linux `.tar.gz` 压缩包。
2. **解压与重命名**:
   解压该压缩包，将解压出来的文件夹重命名为 `jetbrains-toolbox`（去除后缀中的版本号）。
3. **放置于用户级软件目录**:
   将 `jetbrains-toolbox` 文件夹移动到用户主目录下的 `~/.local/share/` 中：
   ```bash
   mv jetbrains-toolbox ~/.local/share/
   ```
   *最终路径形态*: `~/.local/share/jetbrains-toolbox` （例如 `/home/$USER/.local/share/jetbrains-toolbox`）。

---

### 4.2 首次启动与自动快捷方式生成

进入 Toolbox 的 `bin` 目录运行启动程序：

```bash
cd ~/.local/share/jetbrains-toolbox/bin/
./jetbrains-toolbox
```

- **自动配置**: 首次启动时，Toolbox 会自动配置 PATH 环境变量，并在系统应用菜单中生成桌面快捷方式图标 (Desktop Entry)。

---

### 4.3 关键踩坑点：手动创建 `apps` 目录


首次启动后，Toolbox 会在 `~/.local/share/` 下自动创建 `JetBrains/Toolbox` 文件夹。

- **问题现象**: Toolbox 默认预设的 IDE 安装目录为 `~/.local/share/JetBrains/Toolbox/apps`，由于默认**没有**自动创建 `apps` 文件夹，打开 Toolbox 设置界面时会导致工具路径显示红字报错并提示目录不存在。
- **手动解决命令**: 执行以下命令创建 `apps` 文件夹即可消除标红报错：
  ```bash
  mkdir -p ~/.local/share/JetBrains/Toolbox/apps
  ```

---

### 4.4 安装 IDE

完成上述准备后：
1. 打开 JetBrains Toolbox 界面。
2. 选择你需要的工具（如 IntelliJ IDEA, PyCharm, CLion 等）点击 **安装**。
3. 工具会自动下载并解压安装到 `~/.local/share/JetBrains/Toolbox/apps/` 目录下，并自动在系统桌面菜单中生成可执行图标。

---

### 4.5 常见踩坑：中文界面缺失字体显示“口口口”方块乱码解决

首次打开 IntelliJ IDEA、PyCharm 或 CLion 等 IDE 软件时，由于系统缺少中文字体库或字体缓存未注册，可能导致中文界面所有的汉字均显示为“口口口”方块乱码。

#### 解决步骤与命令

在终端运行以下命令安装全套中文字体库（包含 Google Noto CJK 思源黑体/宋体、文泉驿微米黑/正黑）及字体管理工具：

```bash
# 1. 安装基础中文字体族与 fontconfig 工具
sudo dnf install -y google-noto-sans-cjk-fonts google-noto-serif-cjk-fonts wqy-microhei-fonts wqy-zenhei-fonts fontconfig

# 2. 刷新系统字体缓存
sudo fc-cache -fv
```

完成命令后，**重新启动** JetBrains IDE 软件，界面上的中文汉字即可正常显示。


---

## 5. 原生微信 Linux 版 (WeChat for Linux)

腾讯官方推出了原生 Linux 版微信，提供官方 RPM 格式安装包。

### 5.1 下载与安装步骤
1. 打开 [微信 Linux 官方网站](https://linux.weixin.qq.com/)。
2. 在 **x86 架构** 下选择下载 `.rpm` 安装包。
3. 下载完成后，在终端运行以下命令使用 DNF 进行本地安装：
   ```bash
   sudo dnf install -y ~/Downloads/wechat-*.rpm
   ```

---

## 6. WPS Office Linux 办公套件

金山 WPS 官方为 Linux 桌面端提供了功能完备的办公套件。

### 6.1 下载与安装步骤
1. 打开 [WPS Office Linux 官网](https://www.wps.cn/product/wpslinux)。
2. 点击 **立即下载**，选择 **64 位 RPM 包** (x86_64 架构)。
3. 下载完成后，在终端运行以下命令使用 DNF 进行本地安装：
   ```bash
   sudo dnf install -y ~/Downloads/wps-office-*.rpm
   ```

---

## 7. WindTerm 高性能 SSH 终端连接工具 (便携版配置桌面图标)

WindTerm 是 Linux 下功能极强的高性能 SSH/Sftp 终端工具。官方提供免安装的便携（Portable）压缩包。

### 7.1 下载与解压移动
1. 访问官方 [WindTerm Releases 开源下载页面](https://github.com/kingToolbox/WindTerm/releases)。
2. 下载最新的 Linux 便携包（例如 `WindTerm_2.x.x_Linux_Portable_x86_64.zip`）。
3. 解压 zip 压缩包，得到形如 `WindTerm_2.x.x` 的文件夹。
4. 将该文件夹重命名为 `WindTerm`（去除后缀版本号），并移动至用户本地软件目录 `~/.local/share/` 中：
   ```bash
   mv WindTerm ~/.local/share/
   ```
   *最终路径形态*: `~/.local/share/WindTerm` （例如 `/home/$USER/.local/share/WindTerm`）。

---

### 7.2 用户级桌面快捷方式 (Desktop Entry) 自动集成

为了让应用菜单与 Dock 栏能直接搜索并启动 WindTerm，可直接复制自带模版并修改可执行路径与图标：

```bash
# 1. 确保快捷方式存放目录存在
mkdir -p ~/.local/share/applications

# 2. 复制 WindTerm 自带的 desktop 文件模版
cp ~/.local/share/WindTerm/windterm.desktop ~/.local/share/applications/windterm.desktop

# 3. 使用 sed 命令修正 Exec 可执行文件路径
sed -i "s|Exec=/usr/bin/windterm|Exec=/home/$USER/.local/share/WindTerm/WindTerm|g" ~/.local/share/applications/windterm.desktop

# 4. 使用 sed 命令修正 Icon 图标绝对路径
sed -i "s|Icon=windterm|Icon=/home/$USER/.local/share/WindTerm/windterm.png|g" ~/.local/share/applications/windterm.desktop
```

完成上述命令后，在 GNOME 应用程序菜单中即可直接搜索并点击 **WindTerm** 启动并固定至 Dock 栏。





