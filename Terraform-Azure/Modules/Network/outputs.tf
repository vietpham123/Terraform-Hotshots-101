# Outputs to use with VM building
output "Virtual_Network_Name" {
    value = azurerm_virtual_network.hashinet.name
}

output "Subnet_ID" {
    value = azurerm_subnet.hashisubnet.id
}

output "Network_Security_Group" {
    value = azurerm_network_security_group.hashinsg.id
}

output "Resource_Group" {
    value = azurerm_resource_group.morpheusrg.id
}