# GPU 硬件加速与视频解码驱动配置指南 (AMD & Intel)

Fedora 官方基于专利与版权考虑，对显卡的硬件视频编解码（VA-API）进行了裁剪。AMD 与 Intel 两家厂商在 Linux 上的驱动架构与专利处理路径完全不同，本篇记录两类显卡的正确驱动安装、底层差异对比、VA-API 硬解验证以及 AI 超分生态（FSR 4.1 与 XeSS 3）的技术分析。

---

## 1. AMD 显卡 (Radeon 独显 / Ryzen 核显) 驱动配置

AMD 的视频硬解/硬编模块（UVD / VCN）直接集成在 Mesa 驱动内部，与 `radeonsi` 3D 驱动高度耦合。

### 1.1 安装命令

需通过 RPM Fusion 将官方裁剪的 Mesa VA 驱动替换为包含 H.264/H.265 硬解的 `freeworld` 版本：

```bash
sudo dnf install -y mesa-va-drivers-freeworld --allowerasing
```

- **`--allowerasing` 说明**: 允许 DNF 自动替换掉与 `mesa-va-drivers-freeworld` 冲突的原版 `mesa-va-drivers` 软件包。

---

## 2. Intel 显卡 (Arc 独显 / Core Ultra Xe 核显) 驱动配置

对于 Intel 现代 **Xe 架构** 设备（包含 Intel Arc 独显如 Alchemist A770/B580 以及 Core Ultra Xe 核显），在 Linux 下有着非常清晰的分层驱动架构。**正确做法是保持 Fedora 官方 Mesa 驱动原样不动，仅额外安装 RPM Fusion 的媒体驱动**。

### 2.1 Intel Xe 架构 Linux 驱动分层结构

| 驱动分层 | 对应驱动名称 | 作用与功能说明 |
| :--- | :--- | :--- |
| **Linux 内核驱动 (KMD)** | **`xe`** (`xe.ko`) / `i915` | Fedora (Linux 6.8+) 专门为 Xe 架构引入的全新现代内核模块，负责显卡硬件调度与显存管理。 |
| **Mesa Vulkan 3D 驱动 (UMD)** | **`ANV`** (`anv_dri.so`) | Intel 官方高性能 Vulkan 驱动，负责 Steam / Proton (DXVK & VKD3D) 游戏图形渲染。 |
| **Mesa OpenGL 3D 驱动 (UMD)** | **`Iris`** (`iris_dri.so`) | Intel 现代 Gallium3D OpenGL 驱动，负责桌面窗口合成与原生 OpenGL 应用程序。 |
| **视频编解码驱动 (VA-API)** | **`intel-media-driver`** (`iHD`) | 独立的 VA-API 用户态硬件编解码驱动，负责 4K/8K H.264/HEVC/AV1 视频硬解与硬编。 |

### 2.2 驱动安装命令

在 Fedora 下，内核与 Mesa 3D 驱动（`xe` / `ANV` / `Iris`）已经由系统默认提供且极其完善。只需从 RPM Fusion Nonfree 仓库安装 Intel 专属的硬件视频编解码驱动：

```bash
# Intel Arc 独显 (Alchemist / Battlemage) 与 Xe 核显专用媒体驱动
sudo dnf install -y intel-media-driver
```

### 2.3 误装恢复 (避坑说明)

`mesa-va-drivers-freeworld` 包主要是给 AMD 显卡替换 Mesa 驱动使用的。Intel Xe / Arc 显卡**不需要也不建议**使用它。若之前在 Intel 显卡设备上误装了 Freeworld 驱动，可通过以下命令一键还原为官方版本：

```bash
sudo dnf swap -y mesa-va-drivers-freeworld mesa-va-drivers
sudo dnf swap -y mesa-vdpau-drivers-freeworld mesa-vdpau-drivers
```

---

## 3. 为什么 A 卡与 I 卡的视频硬解流程完全不同？

| 对比项目 | Intel 显卡 (Arc 独显 / Xe 核显) | AMD 显卡 (Radeon / Ryzen 核显) |
| :--- | :--- | :--- |
| **3D 图形 (Vulkan & OpenGL)** | Fedora 官方 Mesa (**`ANV`** / **`Iris`**) 驱动 | Fedora 官方 Mesa (`radv` / `radeonsi`) 驱动 |
| **视频加速 (VA-API)** | **独立用户态驱动** `intel-media-driver` (`iHD`) | **直接集成在 Mesa** 驱动内部 |
| **专利受限编解码器处理** | 用独立的 `intel-media-driver` 包处理 | 用 `mesa-va-drivers-freeworld` 替换官方 Mesa 部分 |
| **架构处理机制** | Intel 早期即把视频编解码模块从 3D 驱动中独立拆出 | AMD 视频加速与 3D 驱动高度耦合在 Mesa 项目中 |
| **最终配置总结** | **Mesa 保持原样**，直接安装专用 `intel-media-driver` | **需要替换 Mesa** 的 VA 驱动包为 `freeworld` |


---

## 4. VA-API 硬件解码验证 (vainfo)

无论是 AMD 还是 Intel 显卡，均可安装 `libva-utils` 统一诊断硬件解码支持状态：

```bash
sudo dnf install -y libva-utils && vainfo
```

### 输出验证说明
- **AMD 显卡成功标识**: 终端输出显示 `Trying to open /usr/lib64/dri-freeworld/radeonsi_drv_video.so` 且 `va_openDriver() returns 0`。
- **Intel 显卡成功标识**: 终端输出显示 `Trying to open /usr/lib64/dri/iHD_drv_video.so` 且 `va_openDriver() returns 0`，并列出 H.264 / HEVC / AV1 的 `VAEntrypointVLD` (解码) 与 `VAEntrypointEncSlice` (编码) 支持项目。

---

## 5. Intel Arc 显卡与 XeSS 3 在 Linux 下的生态现状

*(注：本节分析专门针对 Intel Arc 独立显卡如 A770 / B580 以及 Intel Arc核显)*

在 Linux 环境下（含 Steam Proton / Wine），关于 Intel XeSS 3 技术的使用说明如下：

### 5.1 现状与支持程度

| 功能模块 | Windows 平台 | Linux 平台 (原生 / Proton) | 说明 |
| :--- | :--- | :--- | :--- |
| **XeSS Super Resolution (超分)** | 完整支持 (走 XMX 硬件加速) | 仅通用 DP4a / GPU 路径 | 能运行，但缺少 XMX 硬件加速，性能与画质逊于 Windows |
| **XeSS Frame Generation (帧生成)** | 支持 | 基本不可用 | 依赖 Windows 专用闭源二进制库 (.dll) |
| **XeSS 3 Multi-Frame Gen (多帧生成)** | 支持 | 不支持 | 目前为 Windows 专享 |

---

## 6. 深度对比：AMD FSR 4.1 与 Intel XeSS 3 在 Linux (Fedora/Proton) 上的生态落地

进入 AI 渲染时代（机器学习 AI 超分与 AI 帧生成）后，AMD FSR 4.1 与 Intel XeSS 3 在 Linux (Fedora) 平台上的生态落地产生了本质区别：

### 6.1 维度对比矩阵

| 对比维度 | Intel XeSS 3 (Arc 独显 / 核显) | AMD FSR 4.1 (Radeon 独显 / Ryzen 核显) |
| :--- | :--- | :--- |
| **底层实现** | 深度绑定 Windows DX12 专有 API 与闭源动态库 | 基于通用 Vulkan 扩展与开源/半开源管线构建 |
| **Linux / Proton 适配** | 官方未在 Proton 下映射 XMX 硬件加速与多帧生成 | Valve 与 AMD 联合适配，直接写入 Proton 与 VKD3D-Proton |
| **启用难度** | 无法完整开启，开启超分性能常出现逆向下降 | 设置一行环境变量或配合 OptiScaler 注入即可全功能运行 |
| **画质与鬼影表现** | Linux 下被迫走传统计算路径，效果打折 | 借助 ML 机器学习算法大幅改善运动鬼影和细小闪烁 |

---

### 6.2 为什么 FSR 4.1 让 AMD 显卡在 Fedora 上优势更显著？

#### 1. Proton 级别的“无缝升阶”支持
Valve 将 FSR 4.1 深度整合到了 Proton 环境中（例如 Proton Experimental / GE-Proton）。只要系统搭配了最新的 Mesa 驱动（Mesa 25.2+）：
- 在 Steam 启动项中加入环境变量（如 `PROTON_FSR4_UPGRADE=1`），Proton 就会在底层拦截游戏原生的旧版超分请求，直接自动升阶为 FSR 4.1 的 AI 超分。
- 即使游戏原本只支持 DLSS 或旧版 FSR，在 Fedora 上配合 OptiScaler 工具同样能强制注入 FSR 4.1 运行。

#### 2. 硬件算力在 Linux 上被完整释放
FSR 4.1 利用了 RDNA 3（RX 7000 系列）和 RDNA 4（RX 9000 系列）架构中的 **WMMA / INT8 矩阵指令集** 来跑 AI 推理模型。由于 Linux 开源图形驱动（Mesa RADV）更新极快，这部分 AI 算力在 Fedora 上已经被完全吃满，不像 Intel Arc 的 XMX 硬件加速层一直被卡在 Windows 系统的闭源 SDK 里。

---

### 6.3 总结与选型参考

提起 FSR 4.1 的落地表现，更加凸显了 Intel Arc 显卡目前在 Linux 游戏生态中的局限：
- **Intel Arc (如 B580)**：在 Windows 平台体验惊艳，但在 Linux 下由于 XeSS 3 的生态封闭，导致 XMX 硬件加速和多帧生成能力无法被 Proton 充分释放。
- **AMD Radeon**：凭借与 Valve 在 SteamOS / Proton 上的深度联动，让 Linux 用户能够第一时间同步享受到 FSR 4.1 带来的 AI 画质修复与高帧率体验。

在 Fedora 这种更新频繁、追求最新前沿内核与 Mesa 驱动的 Linux 发行版上，拥有 FSR 4.1 生态护航的 AMD 显卡依然是目前综合游戏体验最好的选择。
