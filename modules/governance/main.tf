data "azurerm_policy_definition" "linux_security_agent" {
  name = "62b52eae-c795-44e3-94e8-1b3d264766fb"
}
data "azurerm_policy_definition" "windows_security_agent" {
  name = "e16f967a-aa57-4f5e-89cd-8d1434d0a29a"
}

resource "azurerm_policy_assignment" "audit_linux_agent" {
  name                 = "audit-linux-agent"
  scope                = var.resource_group_name
  policy_definition_id = data.azurerm_policy_definition.linux_security_agent.id
  parameters = {
    effect = { value = "AuditIfNotExists" }
  }
  location = var.location
}

resource "azurerm_policy_assignment" "audit_windows_agent" {
  name                 = "audit-windows-agent"
  scope                = var.resource_group_name
  policy_definition_id = data.azurerm_policy_definition.windows_security_agent.id
  parameters = {
    effect = { value = "AuditIfNotExists" }
  }
  location = var.location
}
