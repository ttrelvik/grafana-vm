output "subnet_id" {
  description = "The ID of the subnet"
  value       = azurerm_subnet.main.id
}

output "public_ip_id" {
  description = "The ID of the public IP"
  value       = azurerm_public_ip.main.id
}

output "public_ip_address" {
  description = "The public IP address"
  value       = azurerm_public_ip.main.ip_address
}