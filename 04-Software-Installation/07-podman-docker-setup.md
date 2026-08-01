# Podman 容器引擎与 Docker Compose V2 配置指南

Fedora 系统默认深度集成 Podman 容器引擎。与传统 Docker 依赖 root 权限后台守护进程不同，Podman 原生支持非 root 用户（Rootless）安全无根运行。本篇记录如何安装 Podman、启用套接字服务并对接原版 Docker Compose V2 的配置与踩坑指南。

---

## 1. 安装 Podman 与 Docker 命令兼容层

通过 Fedora 官方 DNF 仓库安装 Podman 及兼容包：

```bash
sudo dnf install -y podman podman-docker
```

- **`podman`**: 无根守护进程无关的高性能容器引擎。
- **`podman-docker`**: 提供 `/usr/bin/docker` 到 `/usr/bin/podman` 的命令行兼容别名映射。

---

## 2. 启用用户级 Podman Socket 服务 (REST API 支持)

Podman 默认不需要后台守护进程。但大多数 Docker Compose 工具需要通过 UNIX Socket 与 Docker API 通信。在非 root 用户（推荐）下启用并启动用户级 REST API 套接字：

```bash
# 在非 root 用户下启用并立即启动用户级 Socket
systemctl --user enable --now podman.socket

# 验证 Socket 是否正常工作
systemctl --user status podman.socket
```

---

## 3. 配置环境变量指引 Docker 客户端

将 Podman 的套接字路径告知 Docker 客户端。将以下环境变量写入你的 Shell 配置文件（如 `~/.bashrc` 或 `~/.zshrc`）：

```bash
echo 'export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"' >> ~/.bashrc
source ~/.bashrc
```

---

## 4. 安装原生 Docker Compose V2 官方二进制

不安装 `podman-compose`，直接通过 Docker CLI 插件机制安装官方原版的 `docker-compose` 工具对接 Podman：

```bash
# 1. 创建 Docker CLI 插件目录
mkdir -p ~/.docker/cli-plugins

# 2. 下载 Docker Compose V2 最新官方 x86_64 二进制文件
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose

# 3. 赋予可执行权限
chmod +x ~/.docker/cli-plugins/docker-compose
```

---

## 5. 常见踩坑：屏蔽 podman-compose 提示日志

运行 `docker compose version` 测试时，终端可能会出现类似如下提示：

```text
>>>> Executing external compose provider "/usr/bin/podman-compose". Please see podman-compose(1) for how to disable this message. <<<<
```

### 屏蔽提示的解决步骤

在用户配置目录中创建 Podman 配置文件：

```bash
# 1. 创建配置目录（若不存在）
mkdir -p ~/.config/containers

# 2. 创建或编辑 containers.conf 文件
cat << 'EOF' > ~/.config/containers/containers.conf
[engine]
compose_warning_logs = false
EOF
```

创建完成后重新输入 `docker compose version` 再次测试即可屏蔽警告提示。

---

## 6. 可选扩展配置与 Rootless 权限避坑

### 6.1 镜像仓库默认检索补全配置
Podman 默认拉取简写镜像名（例如 `nginx` 而非 `docker.io/library/nginx`）时会提示用户手动选择仓库。若想直接默认从 Docker Hub 自动检索与拉取：

编辑 `/etc/containers/registries.conf` 文件，将 `unqualified-search-registries` 设置为：

```ini
unqualified-search-registries = ["docker.io"]
```

### 6.2 Rootless 非 root 模式端口绑定限制
在非 root 模式（Rootless）下使用 Podman 时，由于 Linux 系统限制，默认无法绑定 1024 以下的特权端口（如 80 或 443）。

- **推荐处理方式**: 在 `docker-compose.yml` 中映射到 1024 以上的非特权端口（如 `8080:80` 或 `8443:443`）。
- **如果必须使用 80 / 443 端口**: 需调整内核非特权起始端口参数：
  ```bash
  sudo sysctl net.ipv4.ip_unprivileged_port_start=0
  ```
