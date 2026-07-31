# Flatpak 与 Flathub 镜像源配置指南

Flatpak 是 Linux 下的主流跨发行版沙盒软件包格式。在国内网络环境下，通过配置中科大 (USTC) 镜像源可以显著提升 Flathub 软件的下载与更新速度。

---

## 1. 添加 Flathub 官方远程源

如果系统中之前从未使用过 Flathub，需要先添加 Flathub 远程仓库地址：

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

---

## 2. 修改为中科大 (USTC) 镜像源

在已有 Flathub 远程源的基础上，执行以下命令将其替换为中科大镜像地址：

```bash
sudo flatpak remote-modify flathub --url=https://mirrors.ustc.edu.cn/flathub
```

---

## 3. 恢复为官方默认源

若后续需要切换回 Flathub 官方默认源，运行以下命令：

```bash
sudo flatpak remote-modify flathub --url=https://dl.flathub.org/repo
```

---

> ℹ️ **版权与许可声明**: 本文档中的镜像替换命令与相关说明摘录/整理自 [中国科学技术大学开源镜像站 Flathub 帮助文档 (USTC Mirror)](https://mirrors.ustc.edu.cn/help/flathub.html)，版权归原维护者所有，**不适用**本知识库的 CC-BY-4.0 许可。
