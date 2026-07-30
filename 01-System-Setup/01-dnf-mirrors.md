# DNF 换源与加速配置

使用 GNU/Linux 软件源一键更换脚本，支持最新的 Fedora 44 等版本。

## 一键换源命令

```bash
bash <(curl -sSL https://linuxmirrors.cn/main.sh)
```

## 换源后更新系统与刷新缓存

换源完成后，务必运行以下命令刷新 DNF 元数据并更新已有软件包：

```bash
sudo dnf update -y
```

---

## 相关链接与参考

- **官方网站 / 说明文档**: [https://linuxmirrors.cn/](https://linuxmirrors.cn/)
- **GitHub 开源项目**: [SuperManito/LinuxMirrors](https://github.com/SuperManito/LinuxMirrors)


