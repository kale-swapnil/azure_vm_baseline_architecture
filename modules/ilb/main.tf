resource "azurerm_lb" "this" {
  name                       = "ilb-${var.base_name}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  sku                        = "Standard"
  frontend_ip_configuration {
    name                          = "ilbFrontend"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.240.4.4"
    zones                         = var.zones
  }
  # backend_address_pool { name = "apiBackendPool" }
  # probe {
  #   name                = "ilbprobe"
  #   protocol            = "Tcp"
  #   port                = 80
  #   interval_in_seconds = 15
  #   number_of_probes    = 2
  # }
  # rule {
  #   name                           = "ilbrule"
  #   frontend_ip_configuration_name = "ilbFrontend"
  #   backend_address_pool_name      = "apiBackendPool"
  #   probe_name                     = "ilbprobe"
  #   protocol                       = "Tcp"
  #   frontend_port                  = 443
  #   backend_port                   = 443
  #   idle_timeout_in_minutes        = 15
  # }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "default"
  target_resource_id         = azurerm_lb.this.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.this.id
  # log {
  #   category_group = "allLogs"; enabled = true
  # }
  # metric {
  #   category = "AllMetrics"; enabled = true
  # }
}

data "azurerm_log_analytics_workspace" "this" {
  name                = var.log_analytics_name
  resource_group_name = var.resource_group_name
}
