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
