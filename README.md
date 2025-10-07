# Ubuntu SSH Node.js Development Environment

## 预装软件

- **基础工具**: curl, unzip, wget, git, build-essential
- **NVM**: v0.40.3 (Node Version Manager)
- **Node.js**: v22.20.0 (通过 NVM 安装)
- **pnpm**: 最新版本 (全局安装)
- **Bun**: 最新版本 (全局安装)
- **SSH**: 继承自基础镜像的 SSH 服务

## 使用方法

### 从 GitHub Container Registry 拉取镜像

```bash
docker pull ghcr.io/YOUR_USERNAME/ubuntu-sshd-node:latest
```

### 运行容器

```bash
# 基本运行（默认密码: root）
docker run -d -p 2222:22 ghcr.io/YOUR_USERNAME/ubuntu-sshd-node:latest

# 挂载工作目录
docker run -d -p 2222:22 -v $(pwd):/workspace ghcr.io/YOUR_USERNAME/ubuntu-sshd-node:latest

# 自定义 root 密码和时区
docker run -d -p 2222:22 \
  -e ROOT_PASSWORD=your_password \
  -e TZ=America/New_York \
  ghcr.io/YOUR_USERNAME/ubuntu-sshd-node:latest
```

### SSH 连接

```bash
ssh root@localhost -p 2222
```

默认密码是 `root`，可以通过环境变量 `ROOT_PASSWORD` 修改。

## 本地构建

```bash
# 克隆仓库
git clone https://github.com/YOUR_USERNAME/ubuntu-sshd-node.git
cd ubuntu-sshd-node

# 构建镜像
docker build -t ubuntu-sshd-node .

# 运行
docker run -d -p 2222:22 ubuntu-sshd-node
```

## 验证安装

连接到容器后，可以验证各工具是否正确安装：

```bash
# 先切换到 bash（Docker exec 默认使用 sh）
bash

# 检查 Node.js 和 npm
node --version
npm --version

# 检查 pnpm
pnpm --version

# 检查 bun
bun --version

# 检查 NVM（需要在 bash 中）
nvm --version
nvm list
```

## 自动部署

本项目配置了 GitHub Actions，当代码推送到 main/master 分支时会自动构建并部署到 GitHub Container Registry。

## 环境变量

- `ROOT_PASSWORD`: SSH 登录密码 (默认: root)
- `TZ`: 时区设置 (默认: Asia/Tokyo)

## 许可证

MIT License
