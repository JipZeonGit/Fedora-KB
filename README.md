# Fedora Workstation 个人折腾与配置知识库

> **一切的前提与基础**: [Fedora Workstation 44 官方镜像下载](https://fedoraproject.org/workstation/download/)  
> 记录 Fedora 系统初始化、镜像源加速、GPU 硬件解码、桌面 UI 美化、常用软件与 AI 编程工具链搭建的个人踩坑与实践指南。

---

## 核心特色

- **开箱即用**: 提供包含交互选择与安全容错的自动化 Shell 安装脚本 [`scripts/install.sh`](./scripts/install.sh)。
- **影音硬解与多媒体**: 整合 AMD Freeworld 驱动与 Intel Xe 架构媒体驱动 (`intel-media-driver`)、原生完整版 FFmpeg 及 MPV 高性能影音播放器，彻底解决 4K/8K 视频硬解难题。
- **精美 UI 调优**: 摆脱原生 GNOME “毛坯房”，恢复右上角**常驻系统托盘图标 (AppIndicator)**、开启窗口右上角**最小化/最大化控制按钮**，打造类似 macOS / Ubuntu 的高效常驻 Dock 栏与快捷键体验。
- **游戏生态与优化**: 原生 RPM Steam 客户端、Gamescope 微合成器（绕过 GNOME Mutter 修复 Proton 窗口标题栏返祖与渲染问题）。
- **无根容器与全栈开发**: 整合 Podman Rootless 无根容器与原生 Docker Compose V2、`fnm` Node.js 环境管理、Temurin JDK 多版本及 Android `adb/fastboot` 调试支持。
- **前沿 AI 工具链**: 涵盖 AI 编程 CLI (OpenCode / MimoCode / agy) 以及最新国内 AI IDE (Qoder CN / TRAE CN)。
- **用户态优先**: 推荐非 root 用户级安全安装，拒绝破坏系统底层。



---

## 知识库目录地图

```text
Fedora-KB/
├── 01-System-Setup/               # 01. 系统初始化与换源
├── 02-Drivers-and-Codecs/         # 02. 驱动与硬件加速编码器
├── 03-Desktop-Environment/        # 03. 桌面环境与 UI 调优 (常驻 Dock、窗口最小化/最大化按钮、系统托盘图标恢复)
├── 04-Software-Installation/      # 04. 常用桌面应用与 AI 开发工具链
└── scripts/                       # 05. 自动化 Shell 脚本
```

---

## 详细文档索引

### 01. 系统初始化 (System Setup)
*基础源与第三方仓库配置*
- [01-dnf-mirrors.md](./01-System-Setup/01-dnf-mirrors.md) — DNF 镜像源一键加速 (`LinuxMirrors`) 与更新
- [02-rpm-fusion.md](./01-System-Setup/02-rpm-fusion.md) — 启用 RPM Fusion 仓库 (Free & Nonfree)

### 02. 驱动与编码器 (Drivers & Codecs)
*显卡硬件加速与闭源音视频解码*
- [01-gpu-drivers.md](./02-Drivers-and-Codecs/01-gpu-drivers.md) — GPU 显卡驱动安装与视频硬件解码配置 (AMD & Intel Xe 架构驱动安装对比、vainfo 诊断、FSR 4.1 与 Intel XeSS 3 在 Linux 下的生态深度对比)

- [02-ffmpeg-codecs.md](./02-Drivers-and-Codecs/02-ffmpeg-codecs.md) — 替换原生完整版 FFmpeg 与 `@multimedia` 闭源解码包

### 03. 桌面环境与 UI 调优 (Desktop Environment)
*告别 GNOME“毛坯房”*
- [01-gnome-extensions.md](./03-Desktop-Environment/01-gnome-extensions.md) — GNOME 界面美化与控制优化 (恢复右上角**系统托盘图标** AppIndicator 并右对齐、开启窗口右上角**最小化/最大化控制按钮**、gsettings 命令行设置、快捷键 `Super+↓/↑`、Dash to Dock 常驻栏)


### 04. 常用软件与 AI 开发工具 (Software & AI Tools)
*常用桌面应用、开发环境与 AI 工具链*
- [01-shell-install-apps.md](./04-Software-Installation/01-shell-install-apps.md) — 常用桌面应用指南 (Steam 与 Gamescope 微合成器、MPV, VS Code, Edge, JetBrains Toolbox, 原生微信, WPS Office, WindTerm)
- [02-flatpak-setup.md](./04-Software-Installation/02-flatpak-setup.md) — Flatpak 与 Flathub 镜像源配置 (中科大 USTC 镜像源添加、修改与恢复)
- [03-spark-store-setup.md](./04-Software-Installation/03-spark-store-setup.md) — 星火应用商店 Spark Store 配置 (COPR 仓库管理、卸载与 APM 包管理)
- [04-nodejs-setup.md](./04-Software-Installation/04-nodejs-setup.md) — Node.js 环境管理指南 (`fnm` 用户级管理、镜像加速与 Corepack)
- [05-ai-tools-and-cli.md](./04-Software-Installation/05-ai-tools-and-cli.md) — AI 编程工具与开发 CLI (OpenCode, MimoCode, agy, GitHub CLI, Qoder CN, TRAE CN)
- [06-podman-docker-setup.md](./04-Software-Installation/06-podman-docker-setup.md) — Podman 与 Docker Compose V2 容器配置 (Rootless 套接字、Compose V2 二进制、containers.conf 避坑与特权端口设置)
- [07-jdk-temurin-setup.md](./04-Software-Installation/07-jdk-temurin-setup.md) — Java / JDK 开发环境指南 (Adoptium 官方 RPM 源、Eclipse Temurin 21 / 17 / 8 多版本安装与 `alternatives` 无缝切换)
- [08-android-tools-adb-setup.md](./04-Software-Installation/08-android-tools-adb-setup.md) — Android Platform Tools 调试指南 (DNF 原生安装 `android-tools` 包含 `adb`/`fastboot`、常用命令与 `adbusers` / udev 权限调优)

### 05. 自动化脚本 (Scripts)
- [install.sh](./scripts/install.sh) — 一键自动化换源、驱动、解码器与日常软件安装脚本


---

## 自动化极速配置

针对新安装的 Fedora 系统，可以直接在终端执行以下 Shell 脚本进行一键初始化：

```bash
chmod +x ./scripts/install.sh
./scripts/install.sh
```

---

## 开源许可协议 (License)

本知识库采用 **双重开源许可证 (Mixed License)** 模式：

- **文字与文档内容**: 采用 [CC-BY-4.0 (知识共享 署名 4.0 国际许可协议)](https://creativecommons.org/licenses/by/4.0/deed.zh) 开源。转载与二次创作请注明原作者与出处。*(注：部分摘录自第三方官方文档的文件如 [`04-nodejs-setup.md`](./04-Software-Installation/04-nodejs-setup.md) 和 [`02-flatpak-setup.md`](./04-Software-Installation/02-flatpak-setup.md) 版权归原官方/维护者所有，不适用于本 CC 许可)*
- **自动化脚本与代码 (`scripts/`)**: 采用 [MIT License](https://opensource.org/licenses/MIT) 开源，允许自由修改与商业分发。

更多细节请查阅 [LICENSE](./LICENSE) 文件。


