#!/usr/bin/env bash

set -e

echo "=== 1. 执行 LinuxMirrors 一键换源 ==="
bash <(curl -sSL https://linuxmirrors.cn/main.sh)

echo "=== 2. 换源后更新系统软件包与软件源缓存 ==="
sudo dnf update -y

echo "=== 3. 安装 RPM Fusion (Free & Nonfree) 仓库 ==="
sudo dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

echo "=== 4. 刷新 DNF 元数据缓存 ==="
sudo dnf makecache

echo "=== 5. 替换完整版 FFmpeg (包含闭源编解码库) ==="
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing

echo "=== 6. 安装多媒体编解码包 (@multimedia) ==="
sudo dnf install -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

echo "=== 7. 安装 AMD Freeworld 硬件解码驱动与诊断工具 ==="
sudo dnf install -y mesa-va-drivers-freeworld --allowerasing
sudo dnf install -y libva-utils

echo "=== 8. 安装 Steam 游戏客户端与 32位 AMD VA-API 驱动 ==="
sudo dnf install -y steam
sudo dnf install -y mesa-va-drivers-freeworld.i686

echo "=== 9. 安装 MPV 播放器 ==="
sudo dnf install -y mpv

echo "=== 10. 安装 GNOME UI 优化扩展与工具 (Dash to Dock, AppIndicator, Tweaks) ==="
sudo dnf install -y gnome-shell-extension-dash-to-dock gnome-shell-extension-appindicator gnome-extensions-app gnome-tweaks


echo "=== 11. 配置窗口右上角开启最小化、最大化按钮 ==="
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

echo "=== 12. 导入微软 GPG 密钥并配置 VS Code / Microsoft Edge 仓库 ==="
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[vscode]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo sh -c 'echo -e "[microsoft-edge]\nname=microsoft-edge\nbaseurl=https://packages.microsoft.com/yumrepos/edge\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/microsoft-edge.repo'

echo "=== 13. 刷新缓存并安装 VS Code、Microsoft Edge 稳定版与 GitHub CLI ==="
sudo dnf makecache
sudo dnf install -y code microsoft-edge-stable gh

echo "=== 全部自动化配置与软件安装已完成 ==="

