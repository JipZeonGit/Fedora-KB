# AI 编程工具、开发 CLI 与 AI Agent 安装指南

本篇记录基于 Node.js 及系统基础环境搭建完成后，常用的 AI 命令行 CLI 工具、GitHub 官方 CLI 以及图形化 AI Agent / IDE 编程环境的安装与配置。

---

## 1. AI 命令行 / CLI 工具用户态一键安装

推荐在用户态（非 `root` 权限）下通过官方一键脚本进行安装，自动写入用户家目录环境。

### 1.1 OpenCode

- **官网**: [opencode.ai](https://opencode.ai/zh)
- **用户态安装命令**:
  ```bash
  curl -fsSL https://opencode.ai/install | bash
  ```

---

### 1.2 MimoCode (小米 AI 编程助手)

- **说明**: 基于 OpenCode 二次开发。
- **官网**: [mimo.xiaomi.com/zh/mimocode](https://mimo.xiaomi.com/zh/mimocode)
- **用户态安装命令**:
  ```bash
  curl -fsSL https://mimo.xiaomi.com/install | bash
  ```

---

### 1.3 Antigravity CLI (agy)

- **官网**: [antigravity.google/download](https://antigravity.google/download)
- **用户态安装命令**:
  ```bash
  curl -fsSL https://antigravity.google/cli/install.sh | bash
  ```

---

## 2. GitHub CLI (gh) 安装与账号授权登录

GitHub 官方命令行工具 `gh` 已内置于 Fedora 官方软件仓库中。

### 2.1 安装命令
```bash
sudo dnf install -y gh
```

### 2.2 账号交互授权登录
安装完成后在终端运行授权交互命令：

```bash
gh auth login
```

#### 🔑 终端交互操作指引
1. **What account do you want to log into?**: 选择 `GitHub.com`。
2. **What is your preferred protocol for Git operations?**: 根据需求选择 `HTTPS` 或 `SSH`。
3. **Authenticate Git with your GitHub credentials?**: 选择 `Yes`。
4. **How would you like to authenticate GitHub CLI?**: 选择 **`Login with a web browser`** (使用 Web 浏览器登录)。
5. 终端会生成唯一的设备验证码 (Device Code)，按回车自动打开浏览器，在验证页面确认并授权登录即可完成绑定。

---

## 3. 图形化 AI Agent 编程工具与 IDE (Qoder CN & TRAE CN)

### 3.1 阿里巴巴 Qoder CN (AI Agent 编程工具)

- **官方下载地址**: [qoder.cn/download](https://qoder.cn/download)
- **安装步骤**:
  1. 访问官网下载 Linux 版本 `.rpm` 软件包。
  2. 下载完成后，在终端运行命令安装：
     ```bash
     sudo dnf install -y ~/Downloads/Qoder-*.rpm
     ```

---

### 3.2 字节跳动 TRAE CN IDE (AI 编程 IDE)

- **官方下载地址**: [trae.cn/ide/download](https://www.trae.cn/ide/download)
- **💡 页面下载避坑技巧**:
  1. 打开下载页面后，滑动到底部。
  2. 底部默认按钮可能显示 `.deb (arm64)`。
  3. **关键操作**: 点击右侧的 **下拉箭头按钮**（触发下拉抽屉菜单）。
  4. 在抽屉列表中选择 **`.rpm (x64)`** 格式进行下载。
- **安装步骤**:
  下载完成后，在终端运行命令进行 DNF 本地安装：
  ```bash
  sudo dnf install -y ~/Downloads/Trae-*.rpm
  ```
