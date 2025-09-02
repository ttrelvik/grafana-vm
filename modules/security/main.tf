resource "azurerm_network_security_group" "main" {
    name = "${var.prefix}-nsg"
    location = var.location
    resource_group_name = var.resource_group_name
    tags = var.tags
}

resource "azurerm_network_security_rule" "ssh" {
    name = "AllowSSH"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = var.ssh_source_address_prefix
    destination_address_prefix = "*"
    resource_group_name = var.resource_group_name
    network_security_group_name = azurerm_network_security_group.main.name
}

# Rule for Grafana
resource "azurerm_network_security_rule" "grafana" {
    name = "AllowGrafana"
    priority = 110
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "3000"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = var.resource_group_name
    network_security_group_name = azurerm_network_security_group.main.name
}

# Rule for Prometheus
resource "azurerm_network_security_rule" "prometheus" {
    name = "AllowPrometheus"
    priority = 120
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "9090"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = var.resource_group_name
    network_security_group_name = azurerm_network_security_group.main.name
}

# Rule for Loki
resource "azurerm_network_security_rule" "loki" {
    name = "AllowLoki"
    priority = 130
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "3100"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = var.resource_group_name
    network_security_group_name = azurerm_network_security_group.main.name
}