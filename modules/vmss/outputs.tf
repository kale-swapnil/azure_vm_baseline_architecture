output "frontend_dns"          { value = azurerm_linux_virtual_machine_scale_set.frontend.fqdn }
output "backend_admin_username"{ value = "admin${substr(var.base_name,0,6)}" }
