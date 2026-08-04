# zRAM 内存压缩与 Btrfs 硬盘 Swap 兜底配置指南

Fedora 默认启用了 `systemd-zram-generator` 机制，通过将部分 RAM 划分为高压缩率的内存 Swap（zRAM）来提升大内存任务下的系统流畅度。但在自定义 zRAM 容量或配合硬盘 Swap 兜底时，存在语法格式与文件系统的踩坑点。本篇记录正确的 zRAM 配置、常见故障排查以及 Btrfs 文件系统下创建硬盘 Swap 兜底的全过程。

---

## 1. zRAM 内存压缩配置指南与踩坑反面教材

Fedora 的 zRAM 配置文件位于 `/etc/systemd/zram-generator.conf`。

### 1.1 正确配置语法范例

编辑 `/etc/systemd/zram-generator.conf` 文件：

```ini
[zram0]
# 方式一：使用以 MiB 为单位的纯数字 (例如 12GiB = 12288 MiB)
zram-size = 12288

# 方式二：或者使用系统官方支持的内存比例算式（例如设为物理内存的 1.5 倍）
# zram-size = ram * 1.5

# 压缩算法选用 zstd
compression-algorithm = zstd
```

---

### 1.2 使配置生效的两种途径

修改保存 `/etc/systemd/zram-generator.conf` 后，可以通过以下任意一种方式使新配置生效：

#### 途径一：懒人一键生效 (推荐)
最简单省心的方式是保存修改后直接重启系统：
```bash
sudo reboot
```
开机后 `systemd-zram-generator` 就会自动以新的参数初始化 `zRAM`。

#### 途径二：免重启终端即时生效
若不想重启系统，可以在终端中顺序执行服务复位与重载命令：

```bash
# 1. 卸载已存在的 zram0 设备
sudo swapoff /dev/zram0 2>/dev/null

# 2. 重置 zram0 设备状态
sudo zramctl --reset /dev/zram0 2>/dev/null

# 3. 重新加载 systemd 生成器并重启服务
sudo systemctl daemon-reload
sudo systemctl restart systemd-zram-setup@zram0.service
```

#### 验证生效命令
```bash
zramctl
free -h
```

---

### 1.3 踩坑反面教材：语法错误导致 os error 12 (Cannot allocate memory)

如果你在配置文件中写错了单位格式，重启服务后可能会导致整个 zRAM 无法启动并挂掉。

#### 常见错误写法
误在配置文件中直接写带字母后缀的单位（例如 `zram-size = 12G`）。

#### 故障现象
运行 `zramctl` 输出为空，`free -h` 显示 Swap 容量为 `0B`，`systemctl status systemd-zram-setup@zram0.service` 报错：

```text
zram-generator: Error: Failed to configure disk size into /sys/block/zram0/disksize
zram-generator: Caused by: Cannot allocate memory (os error 12)
systemd-zram-setup@zram0.service: Main process exited, code=exited, status=1/FAILURE
```

#### 错误根因
在 `zram-generator.conf` 配置规范中，不带公式算式的纯数字配置默认单位必须是 **MiB**（例如 `12288`）。直接写入 `zram-size = 12G` 会导致生成器语法解析换算产生极大溢出数值，向内核 `/sys/block/zram0/disksize` 写入非法尺寸时被内核拒绝并抛出 `ENOMEM (os error 12)` 内存分配失败错。只需修改为纯数字 MiB（如 `12288`）即可解决。



---

## 2. 为什么需要 Btrfs 硬盘 Swapfile 兜底？

### 2.1 zRAM 的本质与极端 OOM 隐患
zRAM 的本质是“用 CPU 算力压缩换取物理内存空间”。假设 6.7GiB 物理内存设置了 12GiB zRAM，按 `zstd` 约 3:1 的典型压缩比计算：
- 当 12GiB zRAM 完全塞满时，其内部压缩数据将真实消耗 3~4GiB 的物理内存。
- 若此时应用自身活跃进程也占用了 3.5GiB 物理内存，真实物理 RAM 将被彻底打满。
- 此时 zRAM 无法再分配空间存放新数据，系统依然会触发内核 OOM Killer 强行杀掉重要进程。

配置一个低优先级的硬盘 Swapfile，可以让系统在极端大内存开销或存在大量不常用“冷数据”时，自动将冷数据从内存排挤到硬盘 Swap，避免物理内存死锁。

---

## 3. Fedora (Btrfs 文件系统) 创建 Swapfile 踩坑指南

Fedora 默认根分区采用了 Btrfs 文件系统。在 Btrfs 上**不能直接使用传统 `dd` 或 `fallocate` 命令创建 Swap 文件**（会导致文件系统写时复制 NOCOW 属性丢失与挂载报错）。

### 3.1 使用 Btrfs 专用命令创建 8GB Swap 文件

必须使用 Btrfs 专门提供的命令进行创建，命令会自动完成文件分配与 NOCOW 禁用处理：

```bash
# 1. 使用 Btrfs 专属命令创建 8GB 的 Swap 文件
sudo btrfs filesystem mkswapfile --size 8g /swapfile

# 2. 启用 Swap 文件并设置较低的优先级 (priority 10)
sudo swapon --priority 10 /swapfile

# 3. 写入 /etc/fstab 实现开机自动挂载
echo '/swapfile none swap defaults,pri=10 0 0' | sudo tee -a /etc/fstab
```

---

## 4. 验证 Swap 空间与优先级顺序

配置完成后，运行以下命令验证 Swap 的生效情况与优先级关系：

```bash
swapon --show
```

### 预期输出
```text
NAME       TYPE      SIZE USED PRIO
/dev/zram0 partition  12G   0B  100 (或 32767，高优先级)
/swapfile  file        8G   0B   10 (低优先级)
```

### 结果说明
- **PRIO (优先级)**: `/dev/zram0` 的优先级为 `100`（高），`/swapfile` 的优先级为 `10`（低）。
- **运行机制**: 系统会绝对优先使用超高速的 zRAM 内存压缩；只有当 12GB 的 zRAM 被完全写满时，系统才会开始向 SSD 硬盘上的 `/swapfile` 写入冷数据进行兜底。
- **总容量验证**: 运行 `free -h`，显示 Swap 总容量为 20GiB（12G zRAM + 8G Swapfile 叠加），完美具备防 OOM 崩溃能力。

---

## 5. 高阶内核调优：配合 zRAM 优化 vm.swappiness 参数

在完成 zRAM 与 Swapfile 配置后，内核的 Swappiness (`vm.swappiness`) 策略是决定系统在重载开发环境（如 IDE、JVM 微服务、Docker 容器）下是否卡顿的关键。

### 5.1 为什么默认值 60 不适合 zRAM 场景？

在 Fedora 终端中查看当前 Swappiness：
```bash
sysctl vm.swappiness
# 输出: vm.swappiness = 60
```

- **为什么默认是 60？**: `60` 是传统 Linux 内核针对“慢速 SSD / 机械硬盘”设计的保守默认值。Fedora 官方在 Swap on zRAM 变更提案与 upstream 维护团队中明确推荐设为高数值 (**180**)，但为了避免强行覆盖用户自定义的全局策略，系统镜像默认仍保留了全局 60。
- **`60` 的性能缺陷**: 当物理内存吃紧时，`60` 会促使内核优先清空系统与 IDE 读写磁盘产生的文件缓存 (Buffer/Cache)，而不是换出冷数据。这会导致 IntelliJ IDEA 项目索引重新读取、Maven 编译与 Docker 镜像读盘变慢卡顿。
- **`180` 的性能优势**: 从 Linux Kernel 5.8 开始，`swappiness` 的上限从 100 提高到了 200。设为 `180` 能让内核以 90% 的偏向度积极将挂在后台的冷数据（如闲置容器、后台服务）压缩放入超高速 zRAM，从而在物理内存中抢出数 GB 空间保留给文件缓存与前台 JVM，使 IDE 响应速度显著提升。

---

### 5.2 使用 systemd 规范配置与持久化生效

在系统配置目录 `/etc/sysctl.d/` 中创建 `99-` 前缀的配置文件，覆盖系统默认值并使用 systemd 原生服务重载：

```bash
# 1. 临时生效测试效果
sudo sysctl vm.swappiness=180

# 2. 写入 systemd 标准 sysctl 配置目录（99- 前缀保证最高优先级）
echo "vm.swappiness = 180" | sudo tee /etc/sysctl.d/99-zram-swappiness.conf

# 3. 使用 systemd-sysctl 原生服务重载内核参数
sudo systemctl restart systemd-sysctl
```

### 5.3 验证持久化生效
运行以下命令检查 Swappiness 与 systemd 服务加载状态：

```bash
# 查看内核 Swappiness 参数
sysctl vm.swappiness
# 预期输出: vm.swappiness = 180

# 检查 systemd-sysctl 服务运行状态
systemctl status systemd-sysctl
# 预期输出: status=0/SUCCESS (Active: active (exited))
```

修改完成后，内核参数将在系统开机时自动由 `systemd-sysctl.service` 读取生效。

---

## 6. 解决 IDE/桌面界面假死卡顿：调整 vm.watermark_scale_factor 内核水位线

在重度 Java 开发、编译或运行多个 Docker 容器时，即使配置了 zRAM 和 Swapfile，偶尔依然会遇到 IDE 界面或桌面突然“假死/卡顿 1~2 秒”的现象。这通常是内核内存回收水位线（Memory Watermarks）缓冲过窄导致的。

### 6.1 桌面卡顿的元凶：内核直接回收 (Direct Reclaim)

Linux 内核维护了三条内存回收水位线：

```text
[ 物理内存 ]
  |
  +--- high  <-- kswapd 停止回收数据
  |      ^
  |      |  (缓冲阶梯差，由 vm.watermark_scale_factor 控制)
  |      v
  +--- low   <-- kswapd 后台线程被唤醒，平滑将冷数据压缩换出到 zRAM
  |      ^
  |      |  (缓冲阶梯差，由 vm.watermark_scale_factor 控制)
  |      v
  +--- min   <-- 强制触发“直接回收 (Direct Reclaim)”，前台线程被挂起暂停
  |
[ 绝对预留保命区 ] (由 vm.min_free_kbytes 决定)
```

- **问题根因**: 默认的 `vm.watermark_scale_factor = 10` 代表阶梯差仅为物理内存区容量的 **0.1%**。在 8GB 内存设备上，`low` 和 `min` 之间的阶梯缓冲带仅有约 100MB~150MB。当在 IDE 中启动微服务、进行多模块编译或瞬时爆发申请内存时，程序会在几十毫秒内迅速穿透这区区 100MB 的缓冲带直冲 `min` 保命线。
- **卡顿机制**: 只要触及 `min` 线，内核就会强制触发 **Direct Reclaim（直接回收）**，此时正在申请内存的前台线程（例如 IDE 界面渲染线程）会被强行挂起暂停，原地等待内核同步释放出空间，导致桌面出现明显的假死或停顿感。

---

### 6.2 调优方案：扩大水位线缓冲区 (`vm.watermark_scale_factor = 100`)

将 `vm.watermark_scale_factor` 从默认的 `10` (0.1%) 提高到 **`100` (1%)**：

1. **原理**: 保持 `min_free_kbytes` 保命底线不动，将 `low` 与 `min` 之间的阶梯缓冲区扩大 **10 倍**（从 100MB 拉大至接近 1GB）。
2. **效果**: 提前唤醒 `kswapd` 后台线程在后台平滑地将冷数据压缩写入 zRAM，为 JVM 爆发性内存申请留足缓冲空间，极大地降低触发“直接回收”的概率，消除 IDE 界面假死。

---

### 6.3 systemd 规范持久化配置与验证

使用 systemd 标准配置目录写入并刷新服务：

```bash
# 1. 查看未修改前的原始内核参数 (默认值通常为 10 和 67584)
sysctl vm.watermark_scale_factor vm.min_free_kbytes

# 2. 写入 systemd 标准 sysctl 配置目录
echo "vm.watermark_scale_factor = 100" | sudo tee /etc/sysctl.d/99-zram-watermark.conf

# 3. 使用 systemd-sysctl 原生服务重载
sudo systemctl restart systemd-sysctl

# 4. 验证参数是否成功修改为 100
sysctl vm.watermark_scale_factor
# 预期输出: vm.watermark_scale_factor = 100
```


