terraform {
  required_providers {
    azurerm = { 
        source = "hashicorp/azurerm"  
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
