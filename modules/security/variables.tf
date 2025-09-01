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

variable "ssh_source_address_prefix" {
  description = "Source address range for SSH access. For security, this should be a specific IP."
  type        = string
}