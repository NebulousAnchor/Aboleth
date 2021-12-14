import os
import subprocess
import sys
import time
from colorama import Fore
from colorama import Style
from subprocess import PIPE, run

def out(command):
    result = run(command, stdout=PIPE, stderr=PIPE, universal_newlines=True, shell=True)
    return result.stdout

extIP = out("curl http://ifconfig.me/ip")

print("The external IP of this machine is: " + extIP + "/32")
kitIP = input("What is the IP you will VPN from?(CIDR notation) ")
custSubnets = int(input("How many external subnets does the customer have? (Max 15) "))
custIP = [input('What is the first customer subnet?(In CIDR notation) ')]
sName = input("What would you like to call this Stack? ")
tagKey = input("Please name a Tag KEY:  ")
tagVal = input("Please name a Tag VALUE for the Key created: ")

if custSubnets >= 2 <=15:
	for i in range(custSubnets-1):
		custIP.append(input('What is the next customer subnet?(CIDR Notation) '))
elif custSubnets > 15:
	print("Max customer subnets is 15")

lookup = "        #automated rules go here"

with open("./app.py", "r+") as f:
	app = f.readlines()
	lineNum = 0
	for (i, line) in enumerate(app):
		if lookup in line:
			lineNum = i+1
	vpnSGrule = "        Redirect_SG.add_ingress_rule(ec2.Peer.ipv4('" + kitIP + "'), ec2.Port.all_traffic(), 'allow ALL Inbound traffic from your IP ')\n"
	app[lineNum] = vpnSGrule
	lineNum = lineNum+1
	for i in range(custSubnets):
		line = int(lineNum + i)
		app[line] = "        Redirect_SG.add_ingress_rule(ec2.Peer.ipv4('" + str(custIP[i]) + "'), ec2.Port.all_traffic(), 'allow ALL Inbound traffic from Customer Subnet')\n"
	lineNum = 0
	lookup = "stackName = "
	for (i, line) in enumerate(app):
		if lookup in line:
			lineNum = i
	stackName = "stackName = 'Mission-Kit-" + sName + "'\n"
	app[lineNum] = stackName
	lineNum = 0
	lookup = "tagKey = "
	for (i, line) in enumerate(app):
		if lookup in line:
			lineNum = i
	app[lineNum] = "tagKey = '" + tagKey + "'\n"
	lineNum = 0
	lookup = "tagVal = "
	for (i, line) in enumerate(app):
		if lookup in line:
			lineNum = i
	app[lineNum] = "tagVal = '" + tagVal + "'\n"


with open("./app.py", "w") as f:
	f.writelines(app)

with open("./auto_gather.sh", "r+") as f:
	auto = f.readlines()
	lineNum = 3
	stackName2 = "stackName='Mission-Kit-" +sName + "'\n"
	auto[lineNum] = stackName2

with open("./auto_gather.sh", "w") as f:
	f.writelines(auto)

os.system('cdk deploy')

print(f'Now we wait {Fore.RED}240 seconds{Style.RESET_ALL}, or {Fore.RED}4 mins{Style.RESET_ALL} before gathering credentials')
time.sleep(240)

os.system('./auto_gather.sh')


