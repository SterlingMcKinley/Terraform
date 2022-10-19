# ======================================================================
# CONFIGURATION FILE NAME: main.tf (file will be rename to main.tf when applied)
# Description: Terraform declarative file to configure an ec2 instance 
#               with security group
#
# REVISION HISTORY: N/A
#
# AUTHOR		               DATE			        DETAILS
# --------------------- --------------- --------------------------------
# Sterling McKinley	     2022-10-18	        Initial version
# --------------------- --------------- --------------------------------

variable "aws_access_key" {}
variable "aws_secret_key" {}


provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region  = "us-east-1"

}

resource "aws_security_group" "web_ssh" {
  name = "ssh-access"
  description = "open ssh traffic"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : "Web-server-SG001"
    "Terraform" : "true"
  } 
}

resource "aws_instance" "web_server01" {
  ami = "ami-08c40ec9ead489470"
  instance_type = "t2.micro"
  key_name = "aws_ec2"  

  tags = {
    "Name" = "Webserver001"
    "Terraform" = "true"
  }
}

output "instance_ip" {
  value = aws_instance.web_server01.public_ip
}
