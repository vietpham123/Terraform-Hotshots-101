# Outputs to use with VM building
output "virtual_network" {
    value = azurerm_virtual_network.hashinet.name
}

output "subnet_name" {
    value = azurerm_subnet.hashisubnet.id
}

output "nsg" {
    value = azurerm_network_security_group.hashinsg.id
}