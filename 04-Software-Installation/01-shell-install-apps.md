# 常用应用软件与开发工具安装指南

记录通过 DNF、RPM Fusion、官方 RPM 软件包以及便携包安装常用桌面与办公应用（MPV 播放器、VS Code、Microsoft Edge、JetBrains Toolbox、原生微信 Linux 版、WPS Office、WindTerm SSH 终端）的操作步骤与配置说明。

---

## 1. MPV 极简高性能媒体播放器


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





