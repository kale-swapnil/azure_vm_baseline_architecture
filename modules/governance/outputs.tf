output "linux_policy_assignment"   { value = azurerm_policy_assignment.audit_linux_agent.id }
output "windows_policy_assignment" { value = azurerm_policy_assignment.audit_windows_agent.id }
