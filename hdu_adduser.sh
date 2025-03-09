#!/bin/bash

# 2025-03-09

if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 用户执行此脚本。"
    exit 1
fi

if [ "$#" -ne 2 ]; then
    echo "用法: $0 <username> <public_key>"
    exit 1
fi

USERNAME=$1
PUBLIC_KEY=$2
PASSWORD=$USERNAME

# 根据主机名设置用户目录
case "$(hostname)" in
    iipl_jump)
        USER_HOME="/home/$USERNAME"
        ;;
    iipl-100)
        USER_HOME="/data0/$USERNAME"
        ;;
    iipl-101)
        USER_HOME="/data0/$USERNAME"
        ;;
    iipl102)
        USER_HOME="/home/$USERNAME"
        ;;
    iipl-103)
        USER_HOME="/data1/$USERNAME"
        ;;
    iipl-104)
        USER_HOME="/home/$USERNAME"
        ;;
    iipl-121)
        USER_HOME="/data0/$USERNAME"
        ;;
    iipl-122)
        USER_HOME="/data0/$USERNAME"
        ;;
    iipl-123)
        USER_HOME="/data0/$USERNAME"
        ;;
    iipl-124)
        USER_HOME="/data0/$USERNAME"
        ;;
    iipl-125)
        USER_HOME="/data0/$USERNAME"
        ;;
    iipl-156)
        USER_HOME="/data0/$USERNAME"
        ;;
    iipl-127)
        USER_HOME="/data0/$USERNAME"
        ;;
    *)
        echo "未知的主机名 $(hostname)，无法确定用户目录。"
        exit 1
        ;;
esac

# 创建用户并设置 home 目录
useradd -m -s /bin/bash -d "$USER_HOME" "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd

echo "用户 $USERNAME 已创建"

# 设置 SSH 目录及权限
mkdir -p "$USER_HOME/.ssh"
chmod 700 "$USER_HOME/.ssh"

echo "$PUBLIC_KEY" > "$USER_HOME/.ssh/authorized_keys"
chmod 600 "$USER_HOME/.ssh/authorized_keys"

# 赋予正确的用户和组权限
chown -R "$USERNAME:$USERNAME" "$USER_HOME"

echo "公钥已添加到 $USERNAME 的 authorized_keys 文件中。"
echo "用户 $USERNAME 已成功创建并配置完成。"
