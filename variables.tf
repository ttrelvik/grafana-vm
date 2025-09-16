variable "environment_variables" {
  description = "A map of environment-specific variables for the Grafana project."
  type        = map(any)
  default = {
    "grafana-dev" = {
      prefix = "grafana-dev"
      # Add any other dev-specific variables here in the future
    }
    "grafana-prod" = {
      prefix = "grafana-prod-1"
      # Add any other prod-specific variables here in the future
    }
  }
}

variable "location" {
  description = "The Azure region where all resources will be deployed."
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default = {
    project    = "Observability Stack"
    managed_by = "Terraform"
  }
}

variable "vnet_address_spaces" {
  description = "The address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "A list of address prefixes for the subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "vm_size" {
  description = "The size (SKU) of the virtual machine."
  type        = string
  default     = "Standard_B2ms"
}

variable "admin_username" {
  description = "The administrator username for the virtual machine."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "The SSH public key used for authentication to the virtual machine."
  type        = string
  sensitive   = true
}

variable "home_ddns_hostname" {
  description = "The DDNS hostname for the home IP address to allow for SSH."
  type        = string
  sensitive   = true
}

variable "runner_ip_address" {
  description = "The IP address of the GitHub Runner to allow for SSH."
  type        = string
  default     = ""
}

variable "dns_zone_name" {
  description = "The name of the existing Azure DNS Zone."
  type        = string
  default     = "az.trelvik.net"
}

variable "dns_resource_group_name" {
  description = "The name of the resource group where the DNS zone is located."
  type        = string
  default     = "rgDns"
}