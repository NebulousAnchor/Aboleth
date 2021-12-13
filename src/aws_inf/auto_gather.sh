#!/bin/bash

GoPhish=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[].Instances[].[InstanceId, Tags[?Key==`Name`].Value[]]' --output text | grep -B 1 'Domain-1-Go-Phish'| grep 'i-')
Redirector=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[].Instances[].[InstanceId, Tags[?Key==`Name`].Value[]]' --output text | grep -B 1 'Domain-2-Redirector' | grep 'i-')

aws ec2 get-console-output  --instance-id $GoPhish --latest --output text > /tmp/d1.txt
aws ec2 get-console-output  --instance-id $Redirector --latest --output text > /tmp/d2.txt 

echo -e "Here is your GoPhish Credentials: \n"
awk '{$1=$2=$3=$4=$5=""; print substr($0,6)}' /tmp/d1.txt | grep username | sed 's/msg/GoPhish/'

echo -e "\nHere is your OpenVPN Certificate: \n"
awk '{$1=$2=$3=""; print substr($0,4)}' /tmp/d2.txt | awk 'flag; /cat \/root\/ubuntu_arm.ovpn/ { flag = 1 }' | awk '1;/\<\/tls-crypt/{exit}' | sed '/SSH keys/d'