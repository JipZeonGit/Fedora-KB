# Node.js 环境管理指南 (fnm)

Node.js 是大部分现代化前端工具、开发命令行 (CLI) 以及 AI 辅助编程工具的前置依赖环境。本篇记录如何通过 **fnm** (Fast Node Manager) 在用户态高效管理和安装 Node.js。

---

## 1. 为什么选择 fnm 用户级管理

- **官方参考文档**: [fnmnode.com 安装指南](https://www.fnmnode.com/zh-cn/install/node)
- **优势**: 免去 `sudo` 提权安装风险，支持单机多主版本（LTS/Latest）秒级无缝切换，并完美兼容项目级 `.node-version` 配置文件。

---

## 2. 快速开始与版本安装

```bash
# 安装最新 LTS（长期支持）版本 (推荐)
fnm install --lts

# 安装最新 Current 版本
fnm install --latest

# 安装指定主版本 (例如 20.x)
fnm install 20

# 验证安装
node -v
npm -v
```

---

## 3. 常见版本切换与默认值配置

```bash
# 切换使用指定主版本
fnm use 20

# 若指定版本未安装，自动下载并切换
fnm use 18 --install-if-missing

# 设置全局默认 Node.js 版本
fnm default 20

# 安装并立即切换使用
fnm install 20 --use

# 查看本地已安装的版本列表
fnm list

# 查看远程可供下载的 LTS 版本
fnm list-remote --lts
```

---

## 4. 国内镜像加速配置 (npmmirror)

在中国大陆网络环境下，建议配置镜像加速以提升 Node.js 二进制包的下载速度：

```bash
# 临时/全局设置镜像环境变量
export FNM_NODE_DIST_MIRROR=https://npmmirror.com/mirrors/node

# 带镜像源进行安装
fnm install 20 --node-dist-mirror=https://npmmirror.com/mirrors/node
```

> **常用镜像源**:
> - npmmirror 镜像: `https://npmmirror.com/mirrors/node`
> - 清华大学开源镜像: `https://mirrors.tuna.tsinghua.edu.cn/nodejs-release`

---

## 5. Corepack (pnpm / yarn) 与项目级自动切换

### 5.1 开启 Corepack 支持
```bash
# 安装 Node.js 时直接开启 Corepack (自动启用 yarn 与 pnpm)
fnm install 20 --corepack-enabled

# 或通过环境变量开启
export FNM_COREPACK_ENABLED=true
```

### 5.2 配合项目 `.node-version` 自动切换
在 Shell 配置文件（如 `~/.bashrc` 或 `~/.zshrc`）中加入自动环境配置脚本：
```bash
eval "$(fnm env --use-on-cd)"
```
配置后，每当进入包含 `.node-version` 或 `.nvmrc` 的项目目录时，`fnm` 会自动读取并切换到对应版本。

---

> ℹ️ **版权与许可声明**: 本文档中的相关命令说明与表格摘录/整理自 [fnm 官方中文文档 (fnmnode.com)](https://www.fnmnode.com/zh-cn/install/node)，版权归原官方作者所有，**不适用**本知识库的 CC-BY-4.0 许可。

