FROM takeyamajp/ubuntu-sshd:ubuntu22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR="/root/.nvm"
ENV NODE_VERSION="22.20.0"
ENV PATH="$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH"

# 保持原镜像的时区设置（可以通过环境变量修改）
# ENV TZ Asia/Tokyo 已在基础镜像中设置
# ENV ROOT_PASSWORD root 已在基础镜像中设置

# 更新包管理器并安装基础工具
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    wget \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 安装 NVM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install $NODE_VERSION \
    && nvm use $NODE_VERSION \
    && nvm alias default $NODE_VERSION

# 安装 pnpm (使用 npm)
RUN . "$NVM_DIR/nvm.sh" \
    && npm install -g pnpm

# 安装 bun (使用官方安装脚本)
RUN curl -fsSL https://bun.sh/install | bash \
    && echo 'export BUN_INSTALL="$HOME/.bun"' >> /root/.bashrc \
    && echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> /root/.bashrc

# 将 bun 添加到 PATH
ENV BUN_INSTALL="/root/.bun"
ENV PATH="$BUN_INSTALL/bin:$PATH"

# 确保 NVM 在新的 shell 会话中可用
# 只配置 .bashrc
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> /root/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /root/.bashrc \
    && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /root/.bashrc

# 在 .profile 中加载 .bashrc (标准做法)
RUN echo '# Load .bashrc if it exists' >> /root/.profile \
    && echo 'if [ -n "$BASH_VERSION" ]; then' >> /root/.profile \
    && echo '    if [ -f "$HOME/.bashrc" ]; then' >> /root/.profile \
    && echo '        . "$HOME/.bashrc"' >> /root/.profile \
    && echo '    fi' >> /root/.profile \
    && echo 'fi' >> /root/.profile

# 设置默认 shell 为 bash
RUN chsh -s /bin/bash root

# 验证安装（使用 bash 避免 shopt 警告）
RUN bash -c '. "$NVM_DIR/nvm.sh" \
    && . "$HOME/.bashrc" \
    && node --version \
    && npm --version \
    && pnpm --version \
    && bun --version'

# 复制自定义 entrypoint 脚本
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 暴露 SSH 端口
EXPOSE 22

# 使用自定义 entrypoint，这样 sshd 会自动启动，同时可以执行用户传入的命令
ENTRYPOINT ["entrypoint.sh"]
CMD []
