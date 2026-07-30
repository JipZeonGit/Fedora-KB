# 启用 RPM Fusion 仓库

RPM Fusion 为 Fedora 社区提供官方仓库中因法律或专利限制而未包含的软件（如闭源显卡驱动、商业格式音视频解码器等）。包含 **Free**（自由开源但含专利）与 **Nonfree**（专有/闭源软件）两个子仓库。

---

## 1. 操作命令

在终端中执行以下命令同时安装 Free 和 Nonfree 仓库配置包：

```bash
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

---

## 2. 交互与后续操作

- **确认安装**: 终端显示事务摘要后，提示 `Is this ok [y/N]:` 时输入 `y` 并回车。
- **GPG 警告提示**: 过程中若出现 `警告：跳过了来自仓库 @commandline 的 2 个软件包的 OpenPGP 检查` 属正常现象（因为是从 URL 直接下载的 RPM 引导包）。

---

## 3. 系统底层变化与作用

- **新增源配置文件**: 在系统 `/etc/yum.repos.d/` 目录下添加 `rpmfusion-free.repo` 和 `rpmfusion-nonfree.repo` 等配置文件。
- **软件库扩展**: 开启后，DNF 即可检索并安装完整版 FFmpeg、NVIDIA 显卡驱动、Steam、特定多媒体插件及解码器。


