provider "aws" {
    region = "us-east-1"  # Change this to the first AWS region
  }
  
  resource "aws_vpc" "company1_vpc" {
    cidr_block = "10.0.0.0/16"
  }
  
  resource "aws_subnet" "company1_subnet" {
    vpc_id     = aws_vpc.company1_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
  }
  
  resource "aws_security_group" "company1_sg" {
    vpc_id = aws_vpc.company1_vpc.id
  
    # Allow incoming SSH (for SSM) from Company 2 EC2 instance
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.1.1.0/24"]  # Assuming the CIDR block of Company 2 subnet
    }
  
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  
  resource "aws_instance" "company1_instance" {
    ami           = "ami-XXXXXXXXXXXXXXXX" # Change this to the AMI ID in us-east-1
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.company1_subnet.id
    security_groups = [aws_security_group.company1_sg.id]
    key_name      = "your_key_name"
  
    # User data for installing/configuring SSM agent
    user_data = <<-EOF
      #!/bin/bash
      sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
      sudo systemctl start amazon-ssm-agent
      EOF
  }
  
provider "aws" {
    alias  = "company2"
    region = "us-west-1"  # Change this to the second AWS region
  }
  
  resource "aws_vpc" "company2_vpc" {
    cidr_block = "10.1.0.0/16"
  }
  
  resource "aws_subnet" "company2_subnet" {
    vpc_id     = aws_vpc.company2_vpc.id
    cidr_block = "10.1.1.0/24"
    availability_zone = "us-west-1a"
  }
  
  resource "aws_security_group" "company2_sg" {
    vpc_id = aws_vpc.company2_vpc.id
  
    # Allow incoming SSH (for SSM) from Company 1 EC2 instance
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.1.0/24"]  # Assuming the CIDR block of Company 1 subnet
    }
  
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  
  resource "aws_instance" "company2_instance" {
    provider      = aws.company2
    ami           = "ami-XXXXXXXXXXXXXXXX" # Change this to the AMI ID in us-west-1
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.company2_subnet.id
    security_groups = [aws_security_group.company2_sg.id]
    key_name      = "your_key_name"
  
    # User data for installing/configuring SSM agent
    user_data = <<-EOF
      #!/bin/bash
      sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
      sudo systemctl start amazon-ssm-agent
      EOF
  }
