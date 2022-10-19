#Followed a tutorial to create this architecture
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.34.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
}

#VPC
resource "aws_vpc" "Terraformvpc" {
  cidr_block = "10.0.0.0/16"
  
  tags  = {
    Name = "Project_VPC"
  }
}


#Internet Gateway
resource "aws_internet_gateway" "TerraformIGW" {
  vpc_id = aws_vpc.Terraformvpc.id

  tags = {
    Name = "Terraform IGW"
  }
}


#Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.Terraformvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TerraformIGW.id
  }

  tags = {
    Name = "PublicRT"
  }
}


#Public Subnet 1
resource "aws_subnet" "Public1A" {
  vpc_id     = aws_vpc.Terraformvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public SBN 1"
  }
}


#Public Subnet 2
resource "aws_subnet" "Public1B" {
  vpc_id     = aws_vpc.Terraformvpc.id
  cidr_block = "10.0.2.0/24"
   availability_zone = "us-east-1b"
   map_public_ip_on_launch = true

  tags = {
    Name = "Public SBN 2"
  }
}

#Associating Public Subnets with Route Table
resource "aws_route_table_association" "Public-Subnet1-RT-Association" {
  subnet_id      = aws_subnet.Public1A.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "Public-Subnet2-RT-Association" {
  subnet_id      = aws_subnet.Public1B.id
  route_table_id = aws_route_table.public_route_table.id
}

#Private Subnet 1
resource "aws_subnet" "Private1a" {
  vpc_id     = aws_vpc.Terraformvpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private SBN 1"
  }
}

#Private Subnet 2
resource "aws_subnet" "Private1b" {
  vpc_id     = aws_vpc.Terraformvpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private SBN 2"
  }
}

#Creating an RDS Database
resource "aws_db_instance" "rds" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "exampleusername"
  password             = "examplepassword"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = "rds_subnet"
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
  
}

#Associate RDS with Subnet Group
resource "aws_db_subnet_group" "rds_subnet" {
  name       = "rds_subnet"
  subnet_ids = [aws_subnet.Private1a.id, aws_subnet.Private1b.id]

  tags = {
    Name = "rds_sbn_Group"
  }
}

#Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "SG for RDS"
  vpc_id      = aws_vpc.Terraformvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    security_groups = [aws_security_group.TF_SG.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "RDS_SG"
  }
}


#Security Group for VPC

resource "aws_security_group" "TF_SG" {
  name        = "TF_SG"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.Terraformvpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/16"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  } 
  
}
 

  
  #Load Balancer
  resource "aws_lb" "TF_LB" {
  name               = "TFLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.TF_SG.id]
  subnets            = [aws_subnet.Public1A.id, aws_subnet.Public1B.id ]

  tags = {
    Environment = "Application"
  }
}

#Creating Public EC2 Instances

resource "aws_instance" "Instance1A" {
  ami           = "ami-026b57f3c383c2eec"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.Public1A.id
  security_groups = [aws_security_group.TF_SG.id]
}

resource "aws_instance" "Instance1B" {
  ami           = "ami-026b57f3c383c2eec"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.Public1B.id
  security_groups = [aws_security_group.TF_SG.id]
  
  
}
