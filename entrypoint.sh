#!/bin/bash
set -e

# 设置默认值
TZ=${TZ:-Asia/Tokyo}
ROOT_PASSWORD=${ROOT_PASSWORD:-root}

# 设置时区
ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime

# 设置 root 密码
echo "root:${ROOT_PASSWORD}" | chpasswd

# 在后台启动 SSH 服务
/usr/sbin/sshd

# 执行用户传入的命令（如果有的话）
if [ $# -gt 0 ]; then
    exec "$@"
else
    # 如果没有传入命令，保持容器运行
    tail -f /dev/null
fi

