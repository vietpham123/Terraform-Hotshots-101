

###########################################################
# AWS provider configuration                              #
###########################################################

provider "aws" {
    region = var.region
    access_key = var.access_key
    secret_key = var.secret_key
}

module "network" {
    source = "./Network"
    vpc_name = var.name
}

module "compute" {
    source = "./Compute"
    raddit_subnet = module.network.WebFarm_Subnet_ID
    security_group = module.network.Security_Group_ID
    compute_name = var.system_name
}