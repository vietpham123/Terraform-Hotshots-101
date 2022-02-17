#############################################################
# Resource Group Creation                                   #
#############################################################

resource "azurerm_resource_group" "morpheusrg" {
    name        = var.name
    location    = var.morpheusregion
}

#############################################################
# Virtual Network Creation                                  #
#############################################################

resource "azurerm_virtual_network" "morpheusnet" {
  name                = "${var.name}vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.morpheusregion
  resource_group_name = var.morpheusrg

  tags = {
    environment = "Terraform Demo"
  }
}

#############################################################
# Subnet Creation                                           #
#############################################################

resource "azurerm_subnet" "morpheussubnet" {
  name                 = "${var.name}subnet"
  resource_group_name  = azurerm_resource_group.morpheusrg.name
  virtual_network_name = azurerm_virtual_network.hashinet.name
  address_prefixes     = ["10.0.1.0/24"]
}

#############################################################
# Security Group and Rule Creation                          #
#############################################################

resource "azurerm_network_security_group" "morpheusnsg" {
  name                = "${var.name}nsg"
  location            = var.morpheusregion
  resource_group_name = azurerm_resource_group.morpheusrg.name

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