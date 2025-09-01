output "network_security_group_id" {
  description = "The ID of the Network Security Group"
  value       = azurerm_network_security_group.main.id
}