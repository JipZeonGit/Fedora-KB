# 星火应用商店 Spark Store 配置指南 (可选)

星火应用商店（Spark Store）由国内开源社区维护，提供了大量生态移植软件与日常桌面应用。Fedora 用户可以通过第三方 COPR 存储库进行安装与使用（此组件为可选扩展，非强制推荐）。

- **星火应用商店官方网站 / 下载入口**: [spark-app.store/download](https://www.spark-app.store/download)

---

## 1. 启用 COPR 仓库与安装 Spark Store 客户端

在终端中执行以下命令启用社区 COPR 存储库并安装客户端主程序：

```bash
# 1. 启用第三方 COPR 存储库 (xmp360/spark-store)
sudo dnf copr enable xmp360/spark-store

# 2. 安装 Spark Store 客户端
sudo dnf install -y spark-store
```

---

## 2. 卸载星火应用商店与移除 COPR 仓库

若后续不需要使用星火应用商店，可通过以下命令实现干净彻底的卸载：

```bash
# 1. 卸载星火应用商店主程序
sudo dnf remove -y spark-store

# 2. 禁用并移除该 COPR 存储库
sudo dnf copr disable xmp360/spark-store
```

---

## 3. 卸载通过 Spark Store 安装的 APM 软件包

星火应用商店内部集成了 APM (Spark Package Manager) 包管理器。在商店界面中下载安装的应用软件包，无法直接通过 DNF 卸载，需使用专门的 `apm` 命令进行删除：

```bash
apm remove <软件包名>
```
