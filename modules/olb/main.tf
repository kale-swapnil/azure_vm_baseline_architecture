locals {
  count = 3
}

resource "azurerm_public_ip" "pips" {
  for_each            = toset(range(0, local.count))
  name                = format("pip-olb-%s-%02d", var.location, each.key)
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
  zones               = var.zones
}

resource "azurerm_lb" "this" {
  name                = "olb-${var.base_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  frontend_ip_configuration {
    # for_each = azurerm_public_ip.pips
    name                          = each.value.name
    public_ip_address_id          = each.value.id
  }
  # backend_address_pool { name = "outboundBackendPool" }
  # outbound_rule {
  #   name                      = "olbrule"
  #   frontend_ip_configuration_ids = [for pip in azurerm_public_ip.pips : azurerm_lb.this.frontend_ip_configuration[pip.name].id]
  #   backend_address_pool_id      = azurerm_lb.this.backend_address_pool[0].id
  #   allocated_outbound_ports     = local.count * 16000
  #   protocol                     = "Tcp"
  #   idle_timeout_in_minutes      = 15
  #   enable_tcp_reset             = true
  # }
}
