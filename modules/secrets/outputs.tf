output "keyvault_name"                     { value = azurerm_key_vault.this.name }
output "gateway_secret_uri"                { value = azurerm_key_vault_secret.appgw_cert.id }
output "trusted_root_secret_uri"           { value = azurerm_key_vault_secret.vmss_root_cert.id }
output "vmss_pfx_secret_uri"               { value = azurerm_key_vault_secret.vmss_pfx.id }
output "private_endpoint_id"               { value = azurerm_private_endpoint.kv.id }
output "private_dns_zone_id"               { value = azurerm_private_dns_zone.kv.id }
