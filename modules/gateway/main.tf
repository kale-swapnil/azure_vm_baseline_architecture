resource "azurerm_user_assigned_identity" "this" {
  name                = "id-appgateway"
  resource_group_name = var.resource_group_name
  location            = var.location
}
# assign KV roles
module "secrets_reader" {
  source              = "../keyvault_role_assignment"
  role_definition_id  = data.azurerm_role_definition.kv_reader.id
  principal_id        = azurerm_user_assigned_identity.this.principal_id
  keyvault_name       = var.keyvault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_role_definition" "kv_reader" {
  name = "21090545-7ca7-4776-b22c-e363652d74d2"
}
data "azurerm_role_definition" "kv_secret_user" {
  name = "4633458b-17de-408e-b874-0445c86b69e6"
}

resource "azurerm_application_gateway" "this" {
  name                = "agw-${var.base_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku {
    name = "WAF_v2"
    tier = "WAF_v2" 
    capacity = 2
  }
  gateway_ip_configuration {
    name      = "ipcfg"
    subnet_id = var.subnet_id
  }
  frontend_port {
    name = "port443"
    port = 443
  }
  frontend_ip_configuration {
    name                 = "public-ip"
    public_ip_address_id = var.public_ip_id
  }
  ssl_certificate {
    name                = "ssl-cert"
    key_vault_secret_id = var.ssl_cert_uri
  }
  trusted_root_certificate {
    name                = "root-cert"
    key_vault_secret_id = var.trusted_root_cert_uri
  }
  http_listener {
    name                           = "listener-https"
    frontend_ip_configuration_name = "public-ip"
    frontend_port_name             = "port443"
    protocol                       = "Https"
    host_name                      = var.domain_name
   # require_server_name_indication = true
    ssl_certificate_name           = "ssl-cert"
  }
  backend_address_pool { name = "webappBackendPool" }
  backend_http_settings {
    name                  = "httpsettings"
    port                  = 443
    protocol              = "Https"
    host_name             = var.domain_name
    trusted_root_certificate_names = ["root-cert"]
    probe_name            = "probe"
    cookie_based_affinity = "Disabled"
  }
  probe {
    name                = "probe"
    protocol            = "Https"
    host                = var.domain_name
    path                = "/favicon.ico"
    match {
      status_code = ["200"]
    }
    interval          = 30
    timeout           = 30
    unhealthy_threshold = 3
  }
  request_routing_rule {
    name                       = "rule"
    rule_type                  = "Basic"
    http_listener_name         = "listener-https"
    backend_address_pool_name  = "webappBackendPool"
    backend_http_settings_name = "httpsettings"
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "default"
  target_resource_id         = azurerm_application_gateway.this.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.this.id
  # log {
  #   category = "allLogs"; enabled = true
  # }
  # metric {
  #   category = "AllMetrics"; enabled = true
  # }
}

data "azurerm_log_analytics_workspace" "this" {
  name                = var.log_analytics_name
  resource_group_name = var.resource_group_name
}
