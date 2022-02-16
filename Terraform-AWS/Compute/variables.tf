################################################
# Terraform variables                          #
################################################

variable "access_key" {
    type = string
}

variable "secret_key" {
    type = string
}

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