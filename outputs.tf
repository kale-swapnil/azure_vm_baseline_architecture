output "vnet_id"          { value = module.networking.vnet_id }
output "appgw_name"       { value = module.gateway.appgw_name }
output "ilb_name"         { value = module.ilb.ilb_name }
output "olb_name"         { value = module.olb.olb_name }
output "vmss_frontend_url"{ value = module.vmss.frontend_dns }
output "vmss_backend_admin"{ value = module.vmss.backend_admin_username }
