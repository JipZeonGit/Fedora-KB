# AMD Freeworld 硬件视频解码驱动配置

Fedora 官方的 Mesa 驱动包因专利限制禁用了 AMD 显卡的 H.264/H.265 硬件视频编解码（VA-API）支持。通过安装 RPM Fusion 提供的 `mesa-va-drivers-freeworld` 驱动，可以开启显卡的硬件解码与编码加速，大幅降低 CPU 占用与功耗。

---

## 1. 安装 AMD Freeworld 硬件加速驱动

在终端中运行以下命令，使用 RPM Fusion 版本的驱动替换官方受限驱动：

```bash
sudo dnf install mesa-va-drivers-freeworld --allowerasing
```

- **`--allowerasing` 说明**: 允许 DNF 自动替换掉与 `mesa-va-drivers-freeworld` 冲突的原版 `mesa-va-drivers` 软件包。

---

## 2. 安装诊断工具并验证硬解状态

安装 VA-API 诊断工具 `libva-utils` 并运行 `vainfo` 检查驱动加载及支持的硬件解码格式：

```bash
sudo dnf install libva-utils && vainfo
```

---

## 3. 验证日志与输出结果分析

以 **AMD Ryzen 5 3500U (Radeon Vega 8 Graphics)** 为例，成功开启硬解后的典型 `vainfo` 终端输出如下：

```text
Trying display: wayland
libva info: VA-API version 1.23.0
libva info: Trying to open /usr/lib64/dri-nonfree/radeonsi_drv_video.so
libva info: Trying to open /usr/lib64/dri-freeworld/radeonsi_drv_video.so
libva info: Found init function __vaDriverInit_1_23
libva info: va_openDriver() returns 0
vainfo: VA-API version: 1.23 (libva 2.23.0)
vainfo: Driver version: Mesa Gallium driver 26.1.5 for AMD Radeon Vega 8 Graphics (radeonsi, raven, ACO, DRM 3.64, 7.1.5-201.fc44.x86_64)
vainfo: Supported profile and entrypoints
      VAProfileVC1Simple              :	VAEntrypointVLD
      VAProfileVC1Main                :	VAEntrypointVLD
      VAProfileVC1Advanced            :	VAEntrypointVLD
      VAProfileH264ConstrainedBaseline:	VAEntrypointVLD
      VAProfileH264ConstrainedBaseline:	VAEntrypointEncSlice
      VAProfileH264Main               :	VAEntrypointVLD
      VAProfileH264Main               :	VAEntrypointEncSlice
      VAProfileH264High               :	VAEntrypointVLD
      VAProfileH264High               :	VAEntrypointEncSlice
      VAProfileHEVCMain               :	VAEntrypointVLD
      VAProfileHEVCMain               :	VAEntrypointEncSlice
      VAProfileHEVCMain10             :	VAEntrypointVLD
      VAProfileVP9Profile0            :	VAEntrypointVLD
      VAProfileVP9Profile2            :	VAEntrypointVLD
      VAProfileNone                   :	VAEntrypointVideoProc
```

### 🔑 核心状态指标解读

1. **驱动加载成功标识**:
   - 看到 `Trying to open /usr/lib64/dri-freeworld/radeonsi_drv_video.so` 表明系统已正确定位到 RPM Fusion 的 Freeworld 驱动路径。
   - `va_openDriver() returns 0` 表明 VA-API 驱动成功初始化并加载。

2. **支持的核心硬解/硬编格式 (`Supported profile`)**:
   - **H.264 (AVC)**: 支持 `VAEntrypointVLD` (硬件解码) 与 `VAEntrypointEncSlice` (硬件编码)。
   - **H.265 (HEVC Main / Main10)**: 支持 8-bit 与 10-bit 4K/8K 视频硬件解码，以及 `EncSlice` 硬件编码。
   - **VP9 (Profile0 / Profile2)**: 解锁 B 站、YouTube 等网页主流 VP9 格式硬解。
   - **VC1**: 支持 VC-1 格式硬件解码。

