# Create Public IPs
resource "azurerm_public_ip" "morpheuspubip" {
  name                = "${var.name}PublicIP"
  location            = var.morpheusregion
  resource_group_name = var.morpheusrg
  allocation_method   = "Dynamic"
}

# Create Network Interface
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

resource "azurerm_network_interface_security_group_association" "morpheusnicsgass" {
  network_interface_id      = azurerm_network_interface.morpheusnic.id
  network_security_group_id = var.vpc_nsg
}

# Create virtual machine
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