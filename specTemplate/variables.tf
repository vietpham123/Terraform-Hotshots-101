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
    default = "us-east-2"
}

################################################
# Terraform variables                          #
################################################

variable "name" {
    type = string
    default = "<%=customOptions.radname%>"
}
