FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV ROOT_PASSWORD=root
ENV NVM_DIR="/root/.nvm"
ENV NODE_VERSION="22.20.0"
ENV PATH="$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH"
ENV BUN_INSTALL="/root/.bun"
ENV PATH="$BUN_INSTALL/bin:$PATH"

# 一次性安装所有系统依赖
RUN apt update && apt install -y \
    # 时区和基础工具
    tzdata \
    # SSH 服务
    openssh-server \
    # 开发工具
    curl \
    unzip \
    wget \
    git \
    build-essential \
    # 清理
    && mkdir /run/sshd \
    # 配置 SSH
    && sed -i 's/^#\(PermitRootLogin\) .*/\1 yes/' /etc/ssh/sshd_config \
    && sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config \
    # 清理缓存
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# 安装 Node.js 开发环境
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
    # 安装 Node.js
    && . "$NVM_DIR/nvm.sh" \
    && nvm install $NODE_VERSION \
    && nvm use $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    # 安装 pnpm
    && npm install -g pnpm \
    # 安装 bun
    && curl -fsSL https://bun.sh/install | bash \
    # 配置环境变量
    && echo 'export NVM_DIR="$HOME/.nvm"' >> /root/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /root/.bashrc \
    && echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /root/.bashrc \
    && echo 'export BUN_INSTALL="$HOME/.bun"' >> /root/.bashrc \
    && echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> /root/.bashrc \
    # 配置 .profile
    && echo '# Load .bashrc if it exists' >> /root/.profile \
    && echo 'if [ -n "$BASH_VERSION" ]; then' >> /root/.profile \
    && echo '    if [ -f "$HOME/.bashrc" ]; then' >> /root/.profile \
    && echo '        . "$HOME/.bashrc"' >> /root/.profile \
    && echo '    fi' >> /root/.profile \
    && echo 'fi' >> /root/.profile \
    # 设置默认 shell
    && chsh -s /bin/bash root \
    # 验证安装
    && bash -c '. "$NVM_DIR/nvm.sh" && . "$HOME/.bashrc" && node --version && npm --version && pnpm --version && bun --version'

# 创建简化的 entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime'; \
    echo 'echo "root:${ROOT_PASSWORD}" | chpasswd'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entry_point.sh; \
    chmod +x /usr/local/bin/entry_point.sh;

EXPOSE 22

ENTRYPOINT ["entry_point.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]
