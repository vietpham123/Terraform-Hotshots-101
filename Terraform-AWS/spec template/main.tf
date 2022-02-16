################################################
# Terraform variables                          #
################################################

################################################
#  Access key, secret variable from tfvars     #
#  in cloud profiles                           #
################################################

variable "access_key" {
    type = string
}

variable "secret_key" {
    type = string
}

################################################
# Region to use for services, customer defined #
################################################

variable "region" {
    type = string
}

################################################
# Terraform variables                          #
################################################

variable "compute_name" {
    type = string
}

variable "vpc_name" {
    type = string
}

###########################################################
# This terraform manifest is used to create the           #
# networking infrastructure needed for an application     #
# by creating VPC, Internet Gateway, Routing Tables,      #
# subnets, security groups.                               #
###########################################################


###########################################################
# AWS provider configuration                              #
###########################################################

provider "aws" {
    region = var.region
    access_key = var.access_key
    secret_key = var.secret_key
}

###########################################################
# Create a new VPC, and associate the 10.0.0.0/16 space   #
###########################################################

resource "aws_vpc" "TFVPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

##########################################################
# Create a new Internet gateway, and associate it with   #
# the newly-created VPC.                                 #
##########################################################

resource "aws_internet_gateway" "NewIGW" {
  vpc_id = aws_vpc.TFVPC.id
  tags = {
    Name = "${var.vpc_name}_IGW"
  }
}

##########################################################
# Filter route tables to (only the main route table)     #
# the new VPC                                            #
##########################################################

data "aws_route_table" "VPC_MAIN_RT" {
  filter {
    name   = "association.main"
    values = ["true"]
  }
  filter {
    name   = "vpc-id"
    values = [aws_vpc.TFVPC.id]
  }
}

##########################################################
# Create a route in the new VPC's main RT, to point      #
# 0/0 to the newly Internet Gateway.                     #
##########################################################

resource "aws_default_route_table" "Default_Route" {
  default_route_table_id = data.aws_route_table.VPC_MAIN_RT.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.NewIGW.id
  }
  tags = {
    Name = "${var.vpc_name}_RE"
 }
}

#########################################################
# Enumerate all available AZ's in the VPC for a         #
# given region                                          #
#########################################################

data "aws_availability_zones" "AZs" {
  state = "available"
}

#########################################################
# Create two subnets in the the Region                  #
#########################################################

#########################################################
# Create a subnet, for the Web tier, in the first AZ    #
# Provide a public IP address to instances launched     #
# in this subnet                                        #
#########################################################

resource "aws_subnet" "WebFarm" {
  availability_zone = element(data.aws_availability_zones.AZs.names, 0)
  vpc_id            = aws_vpc.TFVPC.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true 
    tags = {
    Name = "${var.vpc_name}_Web_Subnet"
  }
}

#########################################################
# Create a subnet, for the Data tier, in the second AZ  #
# Do not provide public IP’s for instances launched in  # 
# this subnet                                           #
#########################################################

resource "aws_subnet" "DataFarm" {
  availability_zone = element(data.aws_availability_zones.AZs.names, 1)
  vpc_id            = aws_vpc.TFVPC.id
  cidr_block        = "10.0.2.0/24"
    tags = {
    Name = "${var.vpc_name}_Data_Subnet"
  }
}

#########################################################
# Build a new Security Group                            #
# Note that the IPv6 entries are commented-out          #
#########################################################

resource "aws_security_group" "Permit_HTTPS_Any" {
  name        = "${var.vpc_name}_Web_ACL"
  description = "Allow inbound web traffic"
  vpc_id      = aws_vpc.TFVPC.id

  ingress {
    description      = "Allow inbound TCP 9292 from any IPv4"
    from_port        = 9292
    to_port          = 9292
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.TFVPC.ipv6_cidr_block]
  }

  ingress {
    description     = "Allow inbound TCP 22 from any IPv4"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.vpc_name}_SG"
  }
}

###########################################################
# This terraform manifest is used to create a compute     #
# instance that provides a basic reddit-like website      #
# that allows users to add links and upvote them          #
# using Ubuntu 16.04, ruby, mongodb                       #
###########################################################

###########################################################
# AWS provider configuration                              #
###########################################################

provider "aws" {
    region = var.region
    access_key = var.access_key
    secret_key = var.secret_key
}

#########################################################
# Enumerate all available AZ's in the VPC for a         #
# given region                                          #
#########################################################

data "aws_availability_zones" "AZs" {
  state = "available"
}

###########################################################
# AWS Instance t2.micro Ubuntu 16.04                      #
###########################################################

resource "aws_instance" "raddit" {
    ami = "ami-05803413c51f242b7"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.WebFarm.id
    associate_public_ip_address = "true"
    vpc_security_group_ids = [aws_security_group.Permit_HTTPS_Any.id]
    availability_zone = element(data.aws_availability_zones.AZs.names, 0)
    tags = {
        Name = var.compute_name
    }

    user_data = <<EOF
#! /bin/bash
sudo git clone https://github.com/Artemmkin/raddit.git /var/lib/raddit
sudo apt-get update
sudo apt-get install -y ruby-full build-essential
sudo gem install bundler -v "$(grep -A 1 "BUNDLED WITH" ~/var/lib/raddit/Gemfile.lock | tail -n 1)"
cd /var/lib/raddit
sudo bundle install
cd
wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
sudo wget https://raw.githubusercontent.com/vietpham123/Automation-HotShots/main/raddit.service -P /etc/systemd/system/
sudo systemctl start raddit
sudo systemctl enable raddit
EOF

    lifecycle {
        ignore_changes = [ami]
    }
}

###########################################################
# Output Public IP                                        #
###########################################################

output "public_ip" {
    value = aws_instance.raddit.public_ip
}