# Java / JDK 开发环境管理指南 (Eclipse Temurin)

Fedora 系统自带 OpenJDK 基础环境，但在企业级开发与生产部署中，由 Eclipse 基金会维护的开源 **Eclipse Temurin** (原 AdoptOpenJDK) 具有极佳的兼容性与稳定性。本篇记录如何在 Fedora 下配置 Adoptium 官方 RPM 仓库、安装 Eclipse Temurin 21 (LTS)、17 (LTS) 和 8 多版本 JDK，并使用原生 `alternatives` 工具进行版本无缝切换。

---

## 1. 添加 Adoptium 官方 DNF 软件源

通过 `sudo tee` 创建并写入 `/etc/yum.repos.d/adoptium.repo` 配置文件，导入 Adoptium 官方 RPM 仓库与 GPG 签名密钥：

```bash
sudo tee /etc/yum.repos.d/adoptium.repo <<'EOF'
[Adoptium]
name=Adoptium
baseurl=https://packages.adoptium.net/artifactory/rpm/fedora/$releasever/$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.adoptium.net/artifactory/api/gpg/key/public
EOF
```

---

## 2. 安装 Eclipse Temurin JDK (多版本)

支持通过 DNF 灵活安装常用的 LTS 主版本 JDK：

### 2.1 安装 Eclipse Temurin 21 JDK (当前最新 LTS)
```bash
sudo dnf install -y temurin-21-jdk
```

### 2.2 安装 Eclipse Temurin 17 JDK (过渡期主流 LTS)
```bash
sudo dnf install -y temurin-17-jdk
```

### 2.3 安装 Eclipse Temurin 8 JDK (老旧项目兼容)
```bash
sudo dnf install -y temurin-8-jdk
```

> **说明**: DNF 在首次安装时会自动提示并导入 OpenPGP 密钥（指纹 `3B04 D753 C905 0D9A 5D34 3F39 843C 48A5 65F8 F04B`），按 `y` 确认导入即可。

---

## 3. 使用 alternatives 配置与无缝切换 Java 版本

Fedora 系统内置 `alternatives` 机制，可以在多个已安装的 JDK 路径之间自由切换默认调用的 `java` 运行环境与 `javac` 编译器。

### 3.1 切换 Java 运行时命令 (`java`)

运行命令行配置工具：
```bash
sudo alternatives --config java
```

根据终端交互菜单提示，输入目标 JDK 对应的编号：

```text
There are 4 programs which provide 'java'.

  Selection    Command
-----------------------------------------------
*+ 1           /usr/lib/jvm/java-25-openjdk/bin/java
   2           /usr/lib/jvm/java-21-temurin-jdk/bin/java
   3           /usr/lib/jvm/java-17-temurin-jdk/bin/java
   4           /usr/lib/jvm/java-8-temurin-jdk/bin/java

Enter to keep the current selection[+], or type selection number: 2
```

### 3.2 切换 Java 编译器 (`javac`)

```bash
sudo alternatives --config javac
```

输入目标对应的编号：

```text
There are 3 programs which provide 'javac'.

  Selection    Command
-----------------------------------------------
*+ 1           /usr/lib/jvm/java-21-temurin-jdk/bin/javac
   2           /usr/lib/jvm/java-17-temurin-jdk/bin/javac
   3           /usr/lib/jvm/java-8-temurin-jdk/bin/javac

Enter to keep the current selection[+], or type selection number: 1
```

---

## 4. 验证当前生效的版本

配置完成后，通过终端校验 `java` 引擎输出：

```bash
java -version
```

**预期成功输出示例 (Temurin 21)**：
```text
openjdk version "21.0.12" 2026-07-21 LTS
OpenJDK Runtime Environment Temurin-21.0.12+8 (build 21.0.12+8-LTS)
OpenJDK 64-Bit Server VM Temurin-21.0.12+8 (build 21.0.12+8-LTS, mixed mode, sharing)
```

校验 `javac` 编译器输出：
```bash
javac -version
```

---

## 5. 配置 JAVA_HOME 环境变量（可选）

为 Maven、Gradle、JetBrains IDE 等自动化构建工具配置全局 `$JAVA_HOME`：

在 `~/.bashrc` 或 `~/.zshrc` 末尾添加：

```bash
# 指向 alternatives 提供的动态链接（自动跟随 alternatives 切换）
export JAVA_HOME=/usr/lib/jvm/java

# 或者显式绑定特定的 Temurin 版本 (如 JDK 21 / 17 / 8)
# export JAVA_HOME=/usr/lib/jvm/java-21-temurin-jdk
# export JAVA_HOME=/usr/lib/jvm/java-17-temurin-jdk
# export JAVA_HOME=/usr/lib/jvm/java-8-temurin-jdk
```

更新环境变量：
```bash
source ~/.bashrc
```
