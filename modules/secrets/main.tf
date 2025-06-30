resource "azurerm_key_vault" "this" {
  name                        = "kv-${var.base_name}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7
  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = []
    ip_rules                   = []
  }
 # tags = var.tags
}

resource "azurerm_key_vault_secret" "appgw_cert" {
  name         = "gateway-public-cert"
  value        = var.app_gateway_certificate_base64
  key_vault_id = azurerm_key_vault.this.id
}
resource "azurerm_key_vault_secret" "vmss_root_cert" {
  name         = "appgw-vmss-webserver-tls"
  value        = var.vmss_public_cert_base64
  key_vault_id = azurerm_key_vault.this.id
}
resource "azurerm_key_vault_secret" "vmss_pfx" {
  name         = "workload-public-private-cert"
  value        = var.vmss_pfx_base64
  content_type = "application/x-pkcs12"
  key_vault_id = azurerm_key_vault.this.id
}

resource "azurerm_private_endpoint" "kv" {
  name                = "pep-kv-${var.base_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "kv-privatelink"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_link" {
  name                  = "${azurerm_private_dns_zone.kv.name}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_a_record" "kv" {
  name                = azurerm_key_vault.this.name
  zone_name           = azurerm_private_dns_zone.kv.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.kv.private_service_connection[0].private_ip_address]
}
