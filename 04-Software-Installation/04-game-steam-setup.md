# Steam 游戏生态与 Gamescope 微合成器配置指南

Fedora 通过 RPM Fusion Nonfree 仓库提供原生 RPM 格式的 Steam 客户端。本篇记录 Steam 客户端的安装、64 位客户端切换、显卡 32 位驱动补充以及基于 Gamescope 微合成器解决 GNOME 环境下 Proton 游戏窗口标题栏“返祖”等故障的详细指南。

---

## 1. 安装 Steam 客户端与依赖

在启用 RPM Fusion Nonfree 仓库的前提下，直接通过 DNF 安装：

```bash
sudo dnf install -y steam
```

### 系统变化与依赖说明
- **依赖拉取**: Steam 原生版本会引入大量 32 位 (`i686`) 架构的兼容运行库（如 `glibc.i686`, `mesa-dri-drivers.i686`, `mesa-vulkan-drivers.i686`, `alsa-plugins-pulseaudio.i686` 等），以保证老旧 32 位 Windows / Linux 游戏的兼容性。
- **扩展工具**: 自动安装 `steam-devices`，配置针对 Gamepad 游戏手柄 (XBox/DualSense/Pro Controller) 的 `udev` 设备权限规则。

---

## 2. 切换至 64 位原生客户端 (Steam RT3 实验性客户端)

默认启动的 Steam 客户端为 32 位版本。可以通过启用 Steam Beta 计划并切换到全新的 **Steam RT3 (64-bit)** 客户端来获得更好的性能与内存管理：

### 操作配置步骤
1. 打开并登录 Steam 客户端。
2. 点击左上角菜单 **Steam** -> **设置 (Settings)**。
3. 进入 **界面 (Interface)** 选项卡。
4. 找到 **参与客户端测试 (Client Beta Participation)**，将其修改为：**`Steam Beta Update`** (加入 Beta 测试)。
5. 滚动到界面设置最下方，勾选启用 **`使用实验性的 Steam RT3 客户端`** (Use experimental Steam RT3 client)。
6. 根据提示点击 **重启 Steam**，客户端重新下载更新后即完成向 64 位架构的切换。

---

## 3. 补充 32 位 AMD VA-API 硬件解码驱动 (推荐)

某些 32 位旧游戏或包含内嵌 CG 视频动画的游戏在播放视频时，若缺乏 32 位的硬件加速驱动可能会导致播放黑屏或卡顿。针对 AMD 显卡设备，建议补充安装 RPM Fusion Freeworld 的 32 位 VA-API 驱动：

```bash
sudo dnf install -y mesa-va-drivers-freeworld.i686
```

- **作用**: 为 32 位环境中的 H.264/HEVC 视频播放提供 AMD GPU 硬件解码加速。

---

## 4. 常见踩坑：GNOME 窗口标题栏“返祖”与 Gamescope 解决方案

在 Fedora Workstation (GNOME) 环境下运行 Steam Proton 游戏时，窗口化模式经常会出现经典 Windows 98/2000 风格的浅色传统标题栏（即“返祖”标题栏）。

### 4.1 原因分析
GNOME 的 Mutter 合成器在窗口装饰 (Window Decorations) 方面存在兼容性 Bug。Valve 为了避免各种窗口崩溃或异常缩放，在 Proton 中主动禁用了 GNOME 原生窗口装饰，强制回退使用 Wine 自画的经典 Windows 风格标题栏。

### 4.2 解决方案 (按推荐程度排序)

#### 方案一：使用 Gamescope 微合成器 (最推荐)
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

#### 方案二：游戏内开启无边框窗口 (Borderless Windowed)
在游戏图形设置中将窗口模式修改为“无边框窗口”，隐藏外部标题栏，获得接近全屏的体验。

#### 方案三：强制使用较旧版本的 Proton
在游戏属性 -> **兼容性** 中强制选择早期版本的 Proton（如 Proton 8 或 Proton 9 早期版本），部分旧版未启用该禁用补丁。

#### 方案四：使用 Proton-GE 社区增强版
通过 ProtonUp-Qt 安装 Proton-GE 补丁版本（特别是开启了原生 Wine-Wayland 支持的版本）。

#### 方案五：等待官方 GNOME 修复
等待 upstream GNOME Mutter 相关修复合并并随 Fedora 更新推送。

---

## 5. ProtonPlus 第三方兼容层管理工具 (Proton-GE / DW-Proton)

ProtonPlus 是一款简洁高效的图形化第三方兼容层管理工具，支持为 Steam、Lutris 等游戏平台一键下载、更新与管理 Proton-GE、DW-Proton 等兼容层。

- **GitHub 开源项目地址**: [Vysp3r/ProtonPlus](https://github.com/Vysp3r/ProtonPlus)
- **Fedora COPR 仓库页面**: [wehagy/protonplus](https://copr.fedorainfracloud.org/coprs/wehagy/protonplus/)

### 5.1 启用 COPR 仓库与 DNF 安装

在终端运行以下命令启用社区 COPR 仓库并安装 ProtonPlus 稳定版：

```bash
# 1. 启用第三方 COPR 存储库 (wehagy/protonplus)
sudo dnf copr enable wehagy/protonplus

# 2. 安装 ProtonPlus 客户端
sudo dnf install -y protonplus
```

### 5.2 使用说明
1. 安装完成后，在应用列表中启动 **ProtonPlus**。
2. 在顶部选择 **工具** 标签，即可查看并一键下载最新的 **Proton-GE** 、 **DW-Proton** 等兼容层。
3. 下载完成后重新启动 Steam 客户端，在游戏的“属性” -> “兼容性”菜单中即可直接选中对应的自定义 Proton 兼容层。

