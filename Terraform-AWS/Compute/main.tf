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
    key_name = var.key_pair
    subnet_id = var.raddit_subnet
    associate_public_ip_address = "true"
    vpc_security_group_ids = [var.security_group]
    availability_zone = element(data.aws_availability_zones.AZs.names, 0)
    tags = {
        Name = var.compute_name
    }

    provisioner "file" {
        source= "~/scripts/configuration.sh"
        destination = "/tmp/configuration.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/configuration.sh",
            "/tmp/configuration.sh",
        ]
    }

    lifecycle {
        ignore_changes = [ami]
    }
}

###########################################################
# configuring system                                      #
###########################################################