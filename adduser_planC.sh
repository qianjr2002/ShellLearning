#!/bin/bash

'''
adduser_planC.sh 根据xxxuser.txt批量开账号
chmod +x adduser_planC.sh
sudo ./adduser_planC.sh
'''
# 检查是否为 root 用户
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 用户执行此脚本。"
    exit 1
fi

# 检查 xxxuser.txt 文件是否存在
USER_FILE="xxxuser.txt"
if [ ! -f "$USER_FILE" ]; then
    echo "$USER_FILE 文件不存在。请确保它存在于当前目录。"
    exit 1
fi

# 设置常量
ADMINISTER="xxxxxx"
PASSWORD="xxxxxx"
DEST_DIR="/home/$ADMINISTER/.ssh"
GROUP="users"

# 确保管理员的 .ssh 目录存在
mkdir -p "$DEST_DIR"
chmod 700 "$DEST_DIR"

# 遍历 122user.txt 文件中的用户名
while read -r USERNAME; do
    # 跳过空行
    if [ -z "$USERNAME" ]; then
        continue
    fi

    echo "正在创建用户: $USERNAME"

    # 添加用户并设置默认密码
    useradd -m -s /bin/bash -G "$GROUP" "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
    echo "用户 $USERNAME 已创建，默认密码为 $PASSWORD"

    # 设置主目录权限
    chmod 750 "/home/$USERNAME"
    echo "已将 /home/$USERNAME 的权限设置为 750"

    # 生成密钥对并配置 authorized_keys
    USER_HOME=$(eval echo "~$USERNAME")
    sudo -u "$USERNAME" bash <<EOF
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t rsa -f ~/.ssh/$USERNAME -N "" -q
cat ~/.ssh/$USERNAME.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
EOF
    echo "密钥对已生成并配置 authorized_keys。"

    # 将私钥复制到管理员的 .ssh 目录中
    cp "$USER_HOME/.ssh/$USERNAME" "$DEST_DIR"
    chmod 600 "$DEST_DIR/$USERNAME"
    echo "私钥 $USERNAME 已复制到 $DEST_DIR"

done < "$USER_FILE"

echo "批量用户创建完成。"
