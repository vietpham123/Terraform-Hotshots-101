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
    subscription_id = var.subid
    client_id = var.clientid
    client_secret = var.clientsecret
    tenant_id = var.tenantid
}

module "network" {
    source = "./Network"
    name = var.name
    morpheusregion = var.azure_region
}

module "compute" {
    source = "./Compute"
    user_name = var.azuser_name
    user_password = var.azpassword
    morpheusrg = module.network.Resource_Group
    morpheusregion = var.azure_region
    morpheussubnet = module.network.Subnet_ID
    morpheusnsg = module.network.Network_Security_Group
    name = var.name
    morpheusregion = var.azure_region
}