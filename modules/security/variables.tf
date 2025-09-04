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

variable "ssh_source_addresses" {
  description = "A list of source IP addresses to allow for SSH access."
  type        = list(string)
  default     = []
}