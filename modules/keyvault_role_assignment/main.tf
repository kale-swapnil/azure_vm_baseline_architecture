data "azurerm_key_vault" "kv" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "this" {
  scope              = data.azurerm_key_vault.kv.id
  role_definition_id = var.role_definition_id
  principal_id       = var.principal_id
}
