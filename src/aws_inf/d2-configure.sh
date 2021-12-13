#!/bin/bash
set -e -x
mkdir -p /tmp/d2
apt update -y
apt install -y unzip socat expect awscli
curl ifconfig.me/ip > /tmp/d2/curl
wget https://git.io/vpn -O /tmp/d2/openvpn-install.sh
wget https://raw.githubusercontent.com/NebulousAnchor/Aboleth/main/src/aws_inf/script.exp -O /tmp/d2/script.exp
newip=$(curl http://ifconfig.me/ip)
sed -i -r '/hostname/s/(\b[0-9]{1,3}\.){3}[0-9]{1,3}\b'/"$newip"/ /tmp/d2/script.exp
chmod +x /tmp/d2/openvpn-install.sh
chmod +x /tmp/d2/script.exp
/tmp/d2/script.exp
echo "complete, ssh key is in /root/ubuntu_arm.ovpn" > /tmp/d2/complete
sleep 5s
cat /root/ubuntu_arm.ovpn