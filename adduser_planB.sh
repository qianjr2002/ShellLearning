#!/bin/bash

# 确保脚本以 root 身份运行
if [ "$(id -u)" -ne 0 ]; then
            echo "请使用 root 用户执行此脚本。"
                exit 1
fi

# 检查参数数量
if [ "$#" -ne 2 ]; then
            echo "用法: $0 <username> <public_key>"
                exit 1
fi

# 设置变量
USERNAME=$1
PUBLIC_KEY=$2
PASSWORD="xxxxxxxxxx"
GROUP="xxxxxx"

# 确保组 speech 存在
if ! getent group "$GROUP" >/dev/null; then
            groupadd "$GROUP"
fi

# 创建用户，主组设为 speech，不创建与用户名相同的组
useradd -m -s /bin/bash -g "$GROUP" -G "$GROUP" "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd

echo "用户 $USERNAME 已创建，默认密码为 $PASSWORD"

# 设置 SSH 目录及权限
USER_HOME="/home/$USERNAME"
mkdir -p "$USER_HOME/.ssh"
chmod 700 "$USER_HOME/.ssh"

echo "$PUBLIC_KEY" > "$USER_HOME/.ssh/authorized_keys"
chmod 600 "$USER_HOME/.ssh/authorized_keys"

# 赋予正确的用户和组权限
chown -R "$USERNAME:$GROUP" "$USER_HOME"

echo "公钥已添加到 $USERNAME 的 authorized_keys 文件中。"
echo "用户 $USERNAME 已成功创建并配置完成。"
