variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "location" {
  description = "Azure location for all resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
}

variable "subnet_id" {
  description = "ID of the subnet"
  type        = string
}

variable "public_ip_id" {
  description = "ID of the public IP"
  type        = string
}

variable "network_security_group_id" {
  description = "ID of the network security group"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for the VM"
  type        = string
  sensitive   = true
}