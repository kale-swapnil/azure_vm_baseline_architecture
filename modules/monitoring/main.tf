resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_monitor_data_collection_rule" "windows" {
  name                = "dcrWindows"
  resource_group_name = var.resource_group_name
  location            = var.location
  data_flow {
    streams = [  ]
    destinations = [  ]
  }
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.windows.id
  destinations {
    
  }
  # … configure sources/destinations per Bicep
}

resource "azurerm_operations_management_solution" "vm_insights" {
  solution_name         = "VMInsights(${azurerm_log_analytics_workspace.this.name})"
  resource_group_name   = var.resource_group_name
  location              = var.location
  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  plan {
    name      = "VMInsights(${azurerm_log_analytics_workspace.this.name})"
    publisher = "Microsoft"
    product   = "OMSGallery/VMInsights"
  }
}
# … other policy assignments & data collection rules, role assignments
