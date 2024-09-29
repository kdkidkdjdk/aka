#!/bin/bash

# 检查并安装必要的软件包
sudo apt-get update
sudo apt-get install pptpd curl iptables -y

# 获取WAN接口的名称
INTERFACE_NAME=$(ip a | awk '/state UP/ {print $2}' | tr -d ':')
if [[ $INTERFACE_NAME == *"w"* ]]; then
    # 检测到无线连接
    wan=$(ip -f inet -o addr show $INTERFACE_NAME | cut -d\  -f 7 | cut -d/ -f 1)
else
    # 检测到有线连接
    wan=$(ip -f inet -o addr show $INTERFACE_NAME | cut -d\  -f 7 | cut -d/ -f 1)
fi

# 获取当前服务器的公网IP
ip=$(curl -s http://checkip.amazonaws.com)

# 设置 Google DNS
echo "设置Google DNS"
sudo bash -c 'echo "ms-dns 8.8.8.8" >> /etc/ppp/pptpd-options'
sudo bash -c 'echo "ms-dns 8.8.4.4" >> /etc/ppp/pptpd-options'

# 修改PPTP配置，使用新的公网IP
echo "修改PPTP配置"
remote_range="${ip%.*}.100-200"  # 使用新的公网IP的子网作为remoteip范围
sudo bash -c "echo 'localip $ip' > /etc/pptpd.conf"
sudo bash -c "echo 'remoteip $remote_range' >> /etc/pptpd.conf"

# 启用IP转发
echo "启用IP转发"
sudo bash -c 'echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf'
sudo sysctl -p

# 配置防火墙
echo "配置防火墙"
sudo iptables -t nat -A POSTROUTING -o $INTERFACE_NAME -j MASQUERADE
sudo iptables --table nat --append POSTROUTING --out-interface ppp0 -j MASQUERADE
sudo iptables -I INPUT -s $ip/8 -i ppp0 -j ACCEPT
sudo iptables --append FORWARD --in-interface $INTERFACE_NAME -j ACCEPT
sudo iptables-save

# 添加VPN用户
echo "设置用户名:"
read username
echo "设置密码:"
read password
sudo bash -c "echo '$username * $password *' >> /etc/ppp/chap-secrets"

# 重启PPTP服务
sudo service pptpd restart

echo "PPTP服务配置完成！"

# 配置systemd服务文件
echo "配置systemd服务以便开机自动运行"
sudo bash -c 'cat << EOF > /etc/systemd/system/update-pptp.service
[Unit]
Description=Update PPTP Configuration on Boot
After=network.target

[Service]
ExecStart=/usr/local/bin/update-pptp.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF'

# 将此脚本保存为 /usr/local/bin/update-pptp.sh
sudo cp "$0" /usr/local/bin/update-pptp.sh
sudo chmod +x /usr/local/bin/update-pptp.sh

# 重新加载 systemd 并启用开机启动
sudo systemctl daemon-reload
sudo systemctl enable update-pptp.service

echo "脚本已设置为开机自动运行！"
