##################################################################
# Terraform Manifest to create Morpheus Spec Template from       #
# to create an application similar to Reddit to post links       #
# and provide the ability to upvote or downvote                  #
##################################################################

##################################################################
# Provider and subscription details for Terraform                #
##################################################################

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

##################################################################
# Variables                                                      #
##################################################################

variable "morpheusrg" {
  type = string
  default = ""
}

variable "morpheusregion" {
  type = string
  default = ""
}

variable "name" {
    type = string
}

variable "user_name" {
  type = string
  default = ""
}

variable "user_password" {
  type = string
  default = ""
}

variable "morpheusrg" {
  type = string
  default = ""
}

variable "morpheusregion" {
  type = string
  default = ""
}

variable "morpheussubnet" {
  type = string
  default = ""
}

variable "morpheusnsg" {
  type = string
  default = ""
}

##################################################################
# Virtual Network Configuration                                  #
##################################################################

resource "azurerm_virtual_network" "morpheusnet" {
  name                = "${var.name}vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.morpheusregion
  resource_group_name = var.morpheusrg

  tags = {
    environment = "Terraform Demo"
  }
}

##################################################################
# Subnet Creation                                                #
##################################################################

resource "azurerm_subnet" "morpheussubnet" {
  name                 = "${var.name}subnet"
  resource_group_name  = var.morpheusrg
  virtual_network_name = azurerm_virtual_network.hashinet.name
  address_prefixes     = ["10.0.1.0/24"]
}

##################################################################
# Network Security Group Creation                                #
##################################################################

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

##################################################################
# Public IP Creation                                             #
##################################################################

resource "azurerm_public_ip" "morpheuspubip" {
  name                = "${var.name}PublicIP"
  location            = var.morpheusregion
  resource_group_name = var.morpheusrg
  allocation_method   = "Dynamic"
}

##################################################################
# Network Interface Creation                                     #
##################################################################

resource "azurerm_network_interface" "morpheusnic" {
  name                = "${var.name}NIC"
  location            = var.morpheusregion
  resource_group_name = var.morpheusrg
  ip_configuration {
    name                          = "${var.name}NicConfiguration"
    subnet_id                     = var.morpheussubnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.morpheuspubip.id
  }
}

###################################################################
# Network Security Group Association Creation                     #
###################################################################

resource "azurerm_network_interface_security_group_association" "morpheusnicsgass" {
  network_interface_id      = azurerm_network_interface.morpheusnic.id
  network_security_group_id = var.vpc_nsg
}

###################################################################
# Virtual Machine Creation                                        #
###################################################################

resource "azurerm_virtual_machine" "radditvm" {
  name                  = "${var.name}-vm"
  location              = var.morpheusregion
  resource_group_name   = var.morpheusrg
  network_interface_ids = [azurerm_network_interface.morpheusnic.id]
  vm_size               = "Standard_DS1_v2"

  delete_os_disk_on_termination    = "true"
  delete_data_disks_on_termination = "true"

  storage_image_reference {
    publisher= "Canonical"
    offer = "UbuntuServer"
    sku = "16.04-LTS"
    version = "latest"
  }

  os_disk {
    name              = "${var.name}-osdisk"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.name}-instance"
    admin_username = var.user_name
    admin_password = var.user_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

##############################################################################
# Configuration of application                                               #
##############################################################################

   user_data = <<EOF
#! /bin/bash
sudo git clone https://github.com/Artemmkin/raddit.git /var/lib/raddit
sudo apt-get update
sudo apt-get install -y ruby-full build-essential
sudo gem install bundler -v "$(grep -A 1 "BUNDLED WITH" ~/var/lib/raddit/Gemfile.lock | tail -n 1)"
cd /var/lib/raddit
sudo bundle install
cd
wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
sudo wget https://raw.githubusercontent.com/vietpham123/Automation-HotShots/main/raddit.service -P /etc/systemd/system/
sudo systemctl start raddit
sudo systemctl enable raddit
EOF
}

###############################################################################
# Outputs                                                                     #
###############################################################################

output "public_ip" {
    value = aws_instance.raddit.public_ip
}