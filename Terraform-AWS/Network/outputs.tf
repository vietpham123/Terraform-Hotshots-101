output "WebFarm_Subnet_ID" {
    value = aws_subnet.WebFarm.id
}
output "DataFarm_Subnet_ID" {
    value = aws_subnet.DataFarm.id
}

output "Security_Group_ID" {
    value = aws_security_group.Permit_HTTPS_Any.id
}