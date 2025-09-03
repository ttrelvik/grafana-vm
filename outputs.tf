output "vm_public_ip" {
  description = "The public IP address of the Grafana VM."
  value       = module.network.public_ip_address
}

output "ssh_command" {
  description = "The command to SSH into the Grafana VM."
  value       = "ssh ${var.admin_username}@${module.network.public_ip_address}"
}

output "fqdn" {
  description = "The fully qualified domain name of the Grafana stack."
  value       = azurerm_dns_a_record.main.fqdn
}

output "dashboard_urls" {
  description = "URLs for the deployed services."
  value = {
    grafana    = "https://grafana.${azurerm_dns_a_record.main.fqdn}"
    prometheus = "https://prometheus.${azurerm_dns_a_record.main.fqdn}"
    loki       = "https://loki.${azurerm_dns_a_record.main.fqdn}/ready"
    traefik    = "https://traefik.${azurerm_dns_a_record.main.fqdn}"
  }
}