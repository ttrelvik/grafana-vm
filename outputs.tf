output "vm_public_ip" {
  description = "The public IP address of the Grafana VM."
  value       = module.network.public_ip_address
}

output "ssh_command" {
  description = "The command to SSH into the Grafana VM."
  value       = "ssh ${var.admin_username}@${module.network.public_ip_address}"
}