terraform {
  required_providers {
    azurerm = { 
        source = "hashicorp/azurerm"  
    }
    dns = {
      source = "hashicorp/dns"
    }
  }
  cloud {
    organization = "trelvik_net"
    workspaces {
      tags = { project = "grafana" }    
    }
  }
}
provider "azurerm" {
  features {}
}

locals {
  env_vars = lookup(var.environment_variables, terraform.workspace, var.environment_variables["grafana-dev"])
}

data "dns_a_record_set" "home_ip" {
  host = var.home_ddns_hostname
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.env_vars.prefix}"
  location = var.location
  tags     = var.tags 
}

module "network" {
  source                  = "./modules/network"
  prefix                  = local.env_vars.prefix
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  tags                    = var.tags
  vnet_address_spaces     = var.vnet_address_spaces
  subnet_address_prefixes = var.subnet_address_prefixes
}

module "security" {
  source                        = "./modules/security"
  prefix                        = local.env_vars.prefix
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  tags                          = var.tags
  ssh_source_address_prefix     = "${data.dns_a_record_set.home_ip.addrs[0]}/32"
}

module "compute" {
  source                    = "./modules/compute"
  prefix                    = local.env_vars.prefix
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  tags                      = var.tags
  subnet_id                 = module.network.subnet_id
  public_ip_id              = module.network.public_ip_id
  network_security_group_id = module.security.network_security_group_id
  vm_size                   = var.vm_size
  admin_username            = var.admin_username
  ssh_public_key            = var.ssh_public_key
}

resource "null_resource" "ansible_provisioner" {
  # This ensures the provisioner only runs after the VM has been fully created
  depends_on = [
    module.compute.vm_id
  ]

  # This provisioner creates the inventory file
  provisioner "local-exec" {
    command = <<EOT
      echo '[servers]' > ./ansible/inventory
      echo 'grafana-vm ansible_host=${module.network.public_ip_address}' >> ./ansible/inventory
    EOT
  }

  # This provisioner runs the playbook
  provisioner "local-exec" {
    working_dir = "${path.root}/ansible"
    command     = "ansible-playbook -i inventory playbook.yml"
  }
}