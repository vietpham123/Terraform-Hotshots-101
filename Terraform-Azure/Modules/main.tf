###########################################################
# AWS provider configuration                              #
###########################################################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
    subscription_id = 
    client_id = 
    client_secret = 
    tenant_id = 
}

module "network" {
    source = "./Network"
    vpc_name = var.name
}

module "compute" {
    source = "./Compute"
    raddit_subnet = module.network.WebFarm_Subnet_ID
    security_group = module.network.Security_Group_ID
    compute_name = var.name
}