#!/bin/bash
set -e -x
mkdir -p /tmp/mytest
apt update -y
apt install -y unzip socat expect awscli
curl ifconfig.me/ip > /tmp/mytest/curl
newip=$(curl http://ifconfig.me/ip)
wget https://git.io/vpn -O /tmp/mytest/openvpn-install.sh
aws s3 cp s3://nebulousscripts/script.exp /tmp/mytest/script.exp
sed -i -r '/hostname/s/(\b[0-9]{1,3}\.){3}[0-9]{1,3}\b'/"$newip"/ /tmp/mytest/script.exp
chmod +x /tmp/mytest/openvpn-install.sh
chmod +x /tmp/mytest/script.exp
/tmp/mytest/script.exp
echo "complete, ssh key is in /root/ubuntu_arm.ovpn" > /tmp/mytest/complete
