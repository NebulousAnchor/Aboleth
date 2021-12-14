import os.path
import secrets

from aws_cdk.aws_s3_assets import Asset

from aws_cdk import (
    aws_ec2 as ec2,
    aws_iam as iam,
    core    
)

dirname = os.path.dirname(__file__)

with open("./d1-configure.sh") as f:
    user_data1 = f.read()

with open("./d2-configure.sh") as f:
    user_data2 = f.read()

class EC2InstanceStack(core.Stack):

    def __init__(self, scope: core.Construct, id: str, **kwargs) -> None:
        super().__init__(scope, id, **kwargs)


        # VPC
        vpc = ec2.Vpc(self, "VPC",
            nat_gateways=0,
            subnet_configuration=[ec2.SubnetConfiguration(name="public",subnet_type=ec2.SubnetType.PUBLIC)],
            )

        # AMI 
        linux = ec2.MachineImage.from_ssm_parameter(
            "/aws/service/canonical/ubuntu/server/focal/stable/current/amd64/hvm/ebs-gp2/ami-id")

        # Instance Role and SSM Managed Policy
        role = iam.Role(self, "InstanceSSM", assumed_by=iam.ServicePrincipal("ec2.amazonaws.com"))

        role.add_managed_policy(iam.ManagedPolicy.from_aws_managed_policy_name("AmazonSSMManagedInstanceCore"))

        ## 👇 Create a SG for a web server
        GoPhish_SG = ec2.SecurityGroup(self, 'go-phish-sg', vpc=vpc, description='security group for GoPhish server')

        Redirect_SG = ec2.SecurityGroup(self, 'redirect-sg', vpc=vpc, description='security group for a redirect server')

        GoPhish_SG.add_ingress_rule(ec2.Peer.any_ipv4(), ec2.Port.tcp(80), 'allow HTTP traffic from anywhere')
        GoPhish_SG.add_ingress_rule(ec2.Peer.any_ipv4(), ec2.Port.tcp(443), 'allow HTTPS traffic from anywhere')
        GoPhish_SG.add_ingress_rule(ec2.Peer.ipv4('10.0.8.102/32'), ec2.Port.all_traffic(), 'allow ALL Inbound traffic from Peer (Domain-2-Redirector)')
        
        Redirect_SG.add_ingress_rule(ec2.Peer.ipv4('10.0.8.101/32'), ec2.Port.all_traffic(), 'allow ALL Inbound traffic from Peer (Domain-1-Go-Phish)')
        #automated rules go here
        Redirect_SG.add_ingress_rule(ec2.Peer.ipv4('174.202.6.134/32'), ec2.Port.all_traffic(), 'allow ALL Inbound traffic from your IP ')
        Redirect_SG.add_ingress_rule(ec2.Peer.ipv4('174.202.6.0/24'), ec2.Port.all_traffic(), 'allow ALL Inbound traffic from Customer Subnet')















        # Instance
        instance1 = ec2.Instance(self, "Domain-1-Go-Phish",
            instance_type=ec2.InstanceType("t3.micro"),
            machine_image=linux,
            vpc = vpc,
            role = role,
            security_group=GoPhish_SG,
            user_data = ec2.UserData.custom(user_data1),
            private_ip_address='10.0.8.101',
            )

        instance2 = ec2.Instance(self, "Domain-2-Redirector",
            instance_type=ec2.InstanceType("t3.micro"),
            machine_image=linux,
            vpc = vpc,
            role = role,
            security_group=Redirect_SG,
            user_data = ec2.UserData.custom(user_data2),
            private_ip_address='10.0.8.102',
            )

tagKey = 'Operation'
tagVal = 'Fumous'
        
app = core.App()
stackName = 'Mission-Kit-Fumous'
EC2InstanceStack(app, stackName )
core.Tags.of(app).add(tagKey, tagVal)
app.synth()

