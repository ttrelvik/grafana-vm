locals {
  # The .fqdn attribute from Azure DNS records includes a trailing dot.
  # We remove it here for creating user-friendly, clickable URLs.
  clean_fqdn = trimsuffix(azurerm_dns_a_record.main.fqdn, ".")
}

output "vm_public_ip" {
  description = "The public IP address of the Grafana VM."
  value       = module.network.public_ip_address
}

output "ssh_command" {
  description = "The command to SSH into the Grafana VM."
  value       = "ssh -i ~/.ssh/github_actions_runner ${var.admin_username}@${module.network.public_ip_address}"
}

output "fqdn" {
  description = "The fully qualified domain name of the Grafana stack."
  value       = local.clean_fqdn
}

output "dashboard_urls" {
  description = "URLs for the deployed services."
  value = {
    traefik    = "https://traefik.${local.clean_fqdn}"
    grafana    = "https://grafana.${local.clean_fqdn}"
    prometheus = "https://prometheus.${local.clean_fqdn}"
    loki       = "https://loki.${local.clean_fqdn}/ready"
  }
}