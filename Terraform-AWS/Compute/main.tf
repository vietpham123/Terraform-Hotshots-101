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
    subnet_id = "subnet-09d414745b9cf51b8"
    associate_public_ip_address = "true"
    vpc_security_group_ids = ["sg-060411117b2284795"]
    key_name = "raddit-user"
    availability_zone = element(data.aws_availability_zones.AZs.names, 0)
    tags = {
        Name = "raddit"
    }
    lifecycle {
        ignore_changes = [ami]
    }
}

###########################################################
# AWS EBS Volume                                          #
###########################################################

#resource "aws_ebs_volume" "raddit_ebs" {
#    availability_zone = element(data.aws_availability_zones.AZs.names, 0)
#    size = 20
#}

###########################################################
# Attach EBS volume                                       #
###########################################################

#resource "aws_volume_attachment" "raddit_ebsatt" {
#    device_name = "dev/sdh"
#    volume_id = aws_ebs_volume.raddit_ebs.id
#    instance_id = aws_instance.raddit.id
#}