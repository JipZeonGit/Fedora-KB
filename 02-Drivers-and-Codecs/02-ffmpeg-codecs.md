# 闭源编码器与原生 FFmpeg 配置

Fedora 官方出于版权与专利考虑，默认内置的 `ffmpeg-free` 裁剪掉了 H.264/H.265/AAC 等专利音视频编解码器。在启用 RPM Fusion 源后，需替换为完整版 `ffmpeg` 并补充各种多媒体格式解码插件。

---

## 1. 替换完整版 FFmpeg

### 终端命令
```bash
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
```

### 交互与响应
1. **确认替换**: 终端提示 `Is this ok [y/N]:` 时输入 `y`。
2. **导入 GPG 密钥**: 首次从 RPM Fusion 安装软件包时，终端会询问是否导入 OpenPGP 密钥：
   ```text
   用户 ID : 「RPM Fusion free repository for Fedora (2020) <rpmfusion-buildsys@lists.rpmfusion.org>」
   指纹：E9A491A3DE247814E7E067EAE06F8ECDD651FF2E
   Is this ok [y/N]:
   ```
   输入 `y` 确认导入。

### 系统变化与效果
- **卸载剪裁版组件**: 移除系统自带的 `ffmpeg-free` 及其配套库（包括 `libavcodec-free`, `libavformat-free`, `libavfilter-free` 等 8 个限制版软件包）。
- **安装完整版依赖**: 从 RPM Fusion 仓库安装无裁切的 `ffmpeg` 与 `ffmpeg-libs`，并自动补齐 `x264-libs` (H.264), `x265-libs` (H.265/HEVC), `vvenc-libs` (VVC), `OpenCL-ICD-Loader` 等硬解与编解码核心依赖库。

---

## 2. 安装完整多媒体编解码组 (@multimedia)

为了让系统播放器、浏览器以及第三方应用支持所有主流多媒体格式及蓝牙 aptX 音频，需补充安装 RPM Fusion 的多媒体增强包。

### 终端命令
```bash
sudo dnf install @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
```

### 参数选项说明
- `--setopt="install_weak_deps=False"`: 禁用弱依赖自动安装，避免引入冗余或不必要的软件包，保持系统干净。
- `--exclude=PackageKit-gstreamer-plugin`: 排除与 PackageKit/DNF5 冲突的插件包。

### 交互与响应
- 提示 `Is this ok [y/N]:` 时输入 `y` 确认安装。

### 系统变化与效果
- **GStreamer 插件补全**: 安装 `gstreamer1-plugins-bad-freeworld` 和 `gstreamer1-plugins-ugly`，为基于 GStreamer 的播放器补齐专利格式硬解支持。
- **图片格式扩展**: 安装 `libheif-freeworld` 与 `libde265`，支持 HEIF / HEIC 高效图片格式的缩略图预览与打开。
- **蓝牙音频增强**: 安装 `pipewire-codec-aptx` 与 `libfreeaptx`，为 PipeWire 音频服务解锁蓝牙设备 aptX / aptX HD 高码率编解码支持。
