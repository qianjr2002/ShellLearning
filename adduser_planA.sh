#!/bin/bash

# 检查是否为 root 用户
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 用户执行此脚本。"
    exit 1
fi

# 检查参数数量
if [ "$#" -ne 3 ]; then
    echo "用法: $0 <username> <keyname> <administername>"
    echo "username: the name of new added user; keyname: the file name of key file; administername: the name of you operator"
    exit 1
fi

# 设置变量
USERNAME=$1
KEYNAME=$2
ADMINISTER=$3
PASSWORD="xxxxxxx"
DEST_DIR="/home/$ADMINISTER/.ssh"
GROUP="xxxxx"

# 创建用户并加入 "speech" 组
useradd -m -s /bin/bash -G "$GROUP" "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "用户 $USERNAME 已创建，并加入 $GROUP 组，默认密码为 $PASSWORD"

# 设置主目录的权限
chmod 750 "/home/$USERNAME"
chgrp "$GROUP" "/home/$USERNAME"
echo "已将 /home/$USERNAME 的权限设置为 750，并将组设置为 $GROUP。"

# 切换到新用户生成密钥对并配置 authorized_keys
USER_HOME=$(eval echo "~$USERNAME")
sudo -u "$USERNAME" bash <<EOF
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t rsa -f ~/.ssh/$KEYNAME -N "" -q
cat ~/.ssh/$KEYNAME.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
EOF
echo "密钥对已生成并配置 authorized_keys。"

# 切换回 root，将生成的私钥复制到目标目录并设置权限
mkdir -p "$DEST_DIR"
cp "$USER_HOME/.ssh/$KEYNAME" "$DEST_DIR"
chmod 777 "$DEST_DIR/$KEYNAME"
echo "私钥已复制到 $DEST_DIR，并设置权限为 777。"

echo "脚本执行完成。用户 $USERNAME 已创建，公私钥已生成并配置。"
