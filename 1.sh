#!/bin/bash

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then
    echo "请以root权限运行此脚本。"
    exit 1
fi

# 显示菜单
while true; do
    echo "请选择一个选项："
    echo "1) 查看服务器及系统的信息"
    echo "2) 更新系统及软件"
    echo "3) 开启BBR"
    echo "4) 退出"
    read -p "请输入选项编号: " choice

    case $choice in
        1)
            echo "服务器及系统信息："
            echo "-------------------"
            echo "主机名: $(hostname)"
            echo "操作系统: $(lsb_release -d | cut -f2)"
            echo "内核版本: $(uname -r)"
            echo "CPU信息: $(lscpu | grep 'Model name' | awk -F: '{print $2}' | xargs)"
            echo "内存信息: $(free -h | grep Mem | awk '{print $2}')"
            echo "磁盘信息: $(df -h / | grep / | awk '{print $2}')"
            echo "-------------------"
            ;;
        2)
            echo "更新系统及软件..."
            apt update && apt upgrade -y
            echo "系统及软件更新完成。"
            ;;
        3)
            echo "开启BBR..."
            modprobe tcp_bbr
            echo "tcp_bbr" >> /etc/modules-load.d/modules.conf
            sysctl -w net.core.default_qdisc=fq
            sysctl -w net.ipv4.tcp_congestion_control=bbr
            echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
            echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
            sysctl -p
            echo "BBR已开启。"
            ;;
        4)
            echo "退出脚本。"
            exit 0
            ;;
        *)
            echo "无效选项，请重新输入。"
            ;;
    esac
done