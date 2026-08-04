#!/usr/bin/env bash

set -e

echo "=== 1. 执行 LinuxMirrors 镜像源配置 (需用户交互选择) ==="
echo "[提示] 下方将进入 LinuxMirrors 交互菜单，请根据终端提示选择适合你网络环境的镜像源（如清华大学、中科大、阿里云等）。"
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

echo "=== 7. 选择并安装 GPU 硬件解码驱动 ==="
echo "请选择你的 GPU 显卡类型："
echo "  1) AMD 显卡 (Radeon 独显 / Ryzen 核显)"
echo "  2) Intel 显卡 (Arc 独显 / Core Ultra Xe 核显)"
echo "  3) 跳过显卡驱动安装"
read -r -p "请输入选项数字 [1-3]: " GPU_CHOICE

INSTALL_AMD_32=false
case "$GPU_CHOICE" in
  1)
    echo "--> 已选择 AMD 显卡：安装 mesa-va-drivers-freeworld 驱动..."
    sudo dnf install -y mesa-va-drivers-freeworld --allowerasing
    INSTALL_AMD_32=true
    ;;
  2)
    echo "--> 已选择 Intel 显卡：安装 intel-media-driver 驱动..."
    sudo dnf install -y intel-media-driver
    ;;
  3)
    echo "--> 跳过显卡驱动安装。"
    ;;
  *)
    echo "--> 未知选项，默认跳过显卡驱动安装。"
    ;;
esac

sudo dnf install -y libva-utils

echo "=== 8. 安装 Steam 游戏客户端与 Gamescope 微合成器 ==="
sudo dnf install -y steam gamescope
if [ "$INSTALL_AMD_32" = true ]; then
  echo "--> 为 AMD 显卡补充 32位 VA-API 解码驱动..."
  sudo dnf install -y mesa-va-drivers-freeworld.i686
fi




echo "=== 9. 安装 MPV 播放器 ==="
sudo dnf install -y mpv

echo "=== 10. 安装 GNOME UI 优化扩展与工具 (Dash to Dock, AppIndicator, Tweaks, Web Connector) ==="
sudo dnf install -y gnome-shell-extension-dash-to-dock gnome-shell-extension-appindicator gnome-extensions-app gnome-tweaks gnome-browser-connector



echo "=== 11. 配置窗口右上角开启最小化、最大化按钮 ==="
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

echo "=== 12. 导入微软 GPG 密钥并配置 VS Code / Microsoft Edge 仓库 ==="
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[vscode]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo sh -c 'echo -e "[microsoft-edge]\nname=microsoft-edge\nbaseurl=https://packages.microsoft.com/yumrepos/edge\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/microsoft-edge.repo'

echo "=== 13. 刷新缓存并安装 VS Code、Microsoft Edge 稳定版与 GitHub CLI ==="
sudo dnf makecache
sudo dnf install -y code microsoft-edge-stable gh

echo "=== 14. 安装基础中文字体族与刷新字体缓存 (防止 JetBrains 软件中文显示方块乱码) ==="
sudo dnf install -y google-noto-sans-cjk-fonts google-noto-serif-cjk-fonts wqy-microhei-fonts wqy-zenhei-fonts fontconfig
sudo fc-cache -fv

echo "=== 15. 安装 Podman 容器引擎与 podman-docker 兼容包 ==="
sudo dnf install -y podman podman-docker

echo "=== 全部自动化配置与软件安装已完成 ==="



