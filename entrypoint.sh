#!/bin/bash
set -e

# 设置默认值
TZ=${TZ:-Asia/Tokyo}
ROOT_PASSWORD=${ROOT_PASSWORD:-root}

# 设置时区
ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime
echo "Timezone set to: ${TZ}"

# 设置 root 密码
echo "root:${ROOT_PASSWORD}" | chpasswd
echo "Root password configured"

# 创建 SSH 运行目录（如果不存在）
mkdir -p /run/sshd

# 在后台启动 SSH 服务
echo "Starting SSH server..."
/usr/sbin/sshd -D -e &
SSHD_PID=$!

# 等待 sshd 启动
sleep 2

# 检查 sshd 是否正在运行
if ps -p $SSHD_PID > /dev/null; then
    echo "SSH server started successfully (PID: $SSHD_PID)"
else
    echo "ERROR: SSH server failed to start!"
    exit 1
fi

# 执行用户传入的命令（如果有的话）
if [ $# -gt 0 ]; then
    echo "Executing command: $@"
    # 不使用 exec，让命令在前台运行，这样 sshd 继续在后台运行
    "$@"
else
    # 如果没有传入命令，保持容器运行
    echo "No command specified, keeping container alive..."
    wait $SSHD_PID
fi

