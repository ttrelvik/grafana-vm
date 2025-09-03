data "azurerm_dns_zone" "main" {
  name                = var.dns_zone_name
  resource_group_name = var.dns_resource_group_name
}

resource "azurerm_dns_a_record" "main" {
  name                = local.env_vars.prefix # e.g., "grafana-dev"
  zone_name           = data.azurerm_dns_zone.main.name
  resource_group_name = data.azurerm_dns_zone.main.resource_group_name
  ttl                 = 300
  records             = [module.network.public_ip_address]
}

resource "azurerm_dns_cname_record" "wildcard" {
  name                = "*.${local.env_vars.prefix}" # e.g., "*.grafana-dev"
  zone_name           = data.azurerm_dns_zone.main.name
  resource_group_name = data.azurerm_dns_zone.main.resource_group_name
  ttl                 = 300
  record              = azurerm_dns_a_record.main.fqdn
}