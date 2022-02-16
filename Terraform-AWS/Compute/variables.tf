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

variable "raddit_subnet" {
    type = string
}

variable "security_group" {
    type = string
}

#variable "key_pair" {
#    type = string
#}

variable "compute_name" {
    type = string
}