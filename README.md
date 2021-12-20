
![alt text](https://github.com/NebulousAnchor/Aboleth/blob/main/Intended_Build.jpg)


# AWS Phishing and Pentest Redirect Cloud Services

## GOAL:  

* ~Create a VPC with 2 EC2 instances~ DONE
* ~Allow access to GoPhish Admin page from DMSS Kit to manage Campaign~ DONE
* ~Own VPC with public subnet, 2 EC2 Instances~ DONE
* ~Based on latest Ubuntu 20.04 AMI~ DONE
* ~System Manager replaces SSH (Remote session available trough the AWS Console or the AWS CLI.)~ DONE
* ~Userdata executes script (`configure.sh`).~ DONE
* ~Include script to pull down GoPhish random generated Password and OpenVPN certificate~ DONE
* Attach a Domain (2 sub domains) via A records
* Create a Amazon Client VPN
* Facilitate Kit PFsense Connection
* Start SoCat redirector



## HOW TO USE:

* ASSUMPTION: You have 
    * AWS Account
    * User with Secret ID and Secret Key ` Go to IAM -> Users in AWS Console and generate user with application credentials`
    * Docker installed and running

* NOW ON DOCKER HUB
* RUN: `docker pull nebulousanchor/aboleth`

* Git clone repository and custom build Docker
* RUN: `docker build -t aboleth/aws_inf ./`
* RUN: `docker run --rm -it aboleth/aws_inf`

From the Docker bash prompt:

* RUN: `aws configure` to set region and AWS credentials. Must use IAM credentials not SSO.

* RUN: `python3 cloud.py` to automate cdk deploy and auto_gather.sh into a timed single script.

* Once runnning, connect to OpenVPN running on Instance 2 using certificate presented:
    * Create A records to point at Domain 1 (GoPhish) and Domain 2 (Redirector) external IPs
    * Access GoPhish @ `10.0.8.101:3333` using presented initial credentials
    * Set up Campaign
    * Run Campaign

* To Access shell on each box use the instance ID and SSM from the docker bash prompt:
    * `aws ec2 describe-instances --filters Name=tag:{KEY},Values={Value} --query 'Reservations[].Instances[].[InstanceId, Tags[?Key==`Name`]| [0].Value]' --output text` Output current instances with names
    * `aws ssm start-session --target i-xxxxxxxxx` remote session for shell access

## Known Challenges/Need to do:

* ~GoPhish Admin page only avaliable to 127.0.0.1:3333 by default.  Config.json can be modified at instance startup using d1-configure.sh to use static Private IP of 10.0.8.101~ DONE
* ~Add security group rule defaults to allow the instances to communicate across static private IPs~ DONE
* Certificate creation/testing for Amazon Client VPN.  Current testing build uses an OpenVPN install script on D2 and requires manually grabbing the .ovpn from the EC2 instance to connect.
* Starting SoCat redirector on D2 requries knowning the VPN connection IP of PFSense (multi-missions make this more difficult?)


## Useful commands

 * `cdk bootstrap`   initialize assets before deploy
 * `cdk synth`       emits the synthesized CloudFormation template
 * `cdk deploy`      deploy this stack to your default AWS account/region
 * `aws ssm start-session --target i-xxxxxxxxx` remote session for shell access
 * `aws ec2 describe-instances --filters Name=instance-state-name,Values=running --query 'Reservations[].Instances[].[InstanceId, Tags[?Key==`Name`].Value[]]' --output text` Output current instances with names

