#!/bin/bash

# 检查是否为 root 用户
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
PASSWORD="xxxxxx"
GROUP="speech"

# 创建用户并加入 "speech" 组
useradd -m -s /bin/bash -G "$GROUP" "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "用户 $USERNAME 已创建，并加入 $GROUP 组，默认密码为 $PASSWORD"

# 创建 .ssh 目录并设置权限
USER_HOME=$(eval echo "~$USERNAME")
mkdir -p "$USER_HOME/.ssh"
chmod 700 "$USER_HOME/.ssh"

# 添加公钥到 authorized_keys
echo "$PUBLIC_KEY" > "$USER_HOME/.ssh/authorized_keys"
chmod 600 "$USER_HOME/.ssh/authorized_keys"
chown -R "$USERNAME:$USERNAME" "$USER_HOME/.ssh"

echo "公钥已添加到 $USERNAME 的 authorized_keys 文件中。"
echo "用户 $USERNAME 已成功创建并配置完成。"
