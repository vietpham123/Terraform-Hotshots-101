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

# Create a resource group
resource "azurerm_resource_group" "morpheusrg" {
    name        = var.name
    location    = var.morpheusregion
}


# Create virtual network
resource "azurerm_virtual_network" "morpheusnet" {
  name                = "${var.name}vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.morpheusregion
  resource_group_name = var.morpheusrg

  tags = {
    environment = "Terraform Demo"
  }
}

# Create subnet
resource "azurerm_subnet" "morpheussubnet" {
  name                 = "${var.name}subnet"
  resource_group_name  = var.morpheusrg
  virtual_network_name = azurerm_virtual_network.hashinet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Network Security Group and Rule
resource "azurerm_network_security_group" "morpheusnsg" {
  name                = "${var.name}nsg"
  location            = var.morpheusregion
  resource_group_name = var.hashirg

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "raddit"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9292"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}