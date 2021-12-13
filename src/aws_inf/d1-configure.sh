#!/bin/bash
set -e -x
mkdir -p /tmp/d1
mkdir -p /opt/gophish
apt update -y
apt install -y unzip socat awscli
curl ifconfig.me/ip > /tmp/d1/curl
newip=$(curl http://ifconfig.me/ip)
wget https://github.com/gophish/gophish/releases/download/v0.11.0/gophish-v0.11.0-linux-64bit.zip -O /tmp/d1/gophish.zip
unzip /tmp/d1/gophish.zip -d /opt/gophish
cd /opt/gophish
chmod +x gophish
sed -i -e '/listen_url/s/127.0.0.1:3333/10.0.8.101:3333/' config.json
/opt/gophish/gophish > /opt/gophish/gophish.log 2>&1 &
sleep 20s
curl -s -k -w "%{http_code}\n" https://10.0.8.101:3333/login -o /dev/null 1> /tmp/d1/curl2
if [[ $(< /tmp/d1/curl2) == 200 ]]; then
	echo "complete" > /tmp/d1/complete
elif [[ $(< /tmp/d1/curl2) != 200 ]]; then
	echo "not complete" > /tmp/d1/not_complete
fi
sleep 30s
cat /opt/gophish/gophish.log


