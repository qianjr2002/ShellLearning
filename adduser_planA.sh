#!/bin/bash

# 检查是否为 root 用户
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 用户执行此脚本。"
    exit 1
fi

# 检查参数数量
if [ "$#" -ne 3 ]; then
    echo "用法: $0 <username> <keyname> <administername>"
    echo "username: 新用户名称; keyname: 密钥文件名; administername: 操作员名称"
    exit 1
fi

# 设置变量
USERNAME=$1
KEYNAME=$2
ADMINISTER=$3
PASSWORD="xxxxxx"
DEST_DIR="/home/$ADMINISTER/.ssh"
GROUP="speech"

# 创建用户并将主组设置为 speech
useradd -m -s /bin/bash -g "$GROUP" "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "用户 $USERNAME 已创建，主组为 $GROUP，默认密码为 $PASSWORD"

# 设置主目录的权限
chmod 750 "/home/$USERNAME"
echo "已将 /home/$USERNAME 的权限设置为 750。"

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
chmod 600 "$DEST_DIR/$KEYNAME"
echo "私钥已复制到 $DEST_DIR，并设置权限为 600。"

echo "脚本执行完成。用户 $USERNAME 已创建，公私钥已生成并配置。"
