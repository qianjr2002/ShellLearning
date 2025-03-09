#!/bin/bash

# 确保脚本以 root 身份运行
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 用户执行此脚本。"
    exit 1
fi

# 检查参数数量
if [ "$#" -lt 3 ]; then
    echo "用法: $0 <username> <keyname> <administername> [public_key]"
    echo "username: the name of new added user"
    echo "keyname: the file name of key file"
    echo "administername: the name of you operator"
    echo "public_key: optional public key for SSH authentication"
    exit 1
fi

# 读取参数
USERNAME=$1
KEYNAME=$2
ADMINISTER=$3
PUBLIC_KEY=${4:-""}  # 可选参数
PASSWORD="xxxxxxxx"
GROUP="xxxxx"
DEST_DIR="/home/$ADMINISTER/.ssh"

# 确保 speech 组存在
if ! getent group "$GROUP" >/dev/null; then
    groupadd "$GROUP"
fi

# 创建用户并加入 "speech" 组
useradd -m -s /bin/bash -g "$GROUP" -G "$GROUP" "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "用户 $USERNAME 已创建，并加入 $GROUP 组，默认密码为 $PASSWORD"

# 设置主目录权限
chmod 750 "/home/$USERNAME"
chgrp "$GROUP" "/home/$USERNAME"
echo "已将 /home/$USERNAME 的权限设置为 750，并将组设置为 $GROUP。"

# 切换到新用户生成密钥对，并配置 authorized_keys（planA）
USER_HOME=$(eval echo "~$USERNAME")
sudo -u "$USERNAME" bash <<EOF
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t rsa -f ~/.ssh/$KEYNAME -N "" -q
cat ~/.ssh/$KEYNAME.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
EOF
echo "密钥对已生成并配置 authorized_keys。"

# 复制私钥到管理员 SSH 目录，并保持 777 权限
mkdir -p "$DEST_DIR"
cp "$USER_HOME/.ssh/$KEYNAME" "$DEST_DIR"
chmod 777 "$DEST_DIR/$KEYNAME"
echo "私钥已复制到 $DEST_DIR，并设置权限为 777"

# 如果提供了公钥，额外添加（planB）
if [ -n "$PUBLIC_KEY" ]; then
    echo "$PUBLIC_KEY" >> "$USER_HOME/.ssh/authorized_keys"
    chmod 600 "$USER_HOME/.ssh/authorized_keys"
    echo "提供的公钥已添加到 $USERNAME 的 authorized_keys"
fi

# 设置文件所有者和权限
chown -R "$USERNAME:$GROUP" "$USER_HOME/.ssh"
echo "用户 $USERNAME 的 SSH 目录权限已正确配置。"

echo "脚本执行完成。用户 $USERNAME 已创建，公私钥已生成并配置。"
