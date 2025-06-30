module "networking" {
  source              = "./modules/networking"
  location            = var.location
  resource_group_name = var.resource_group_name
  log_analytics_name  = module.monitoring.log_analytics_workspace_name
  tags = var.tags
  zones = var.zones
}

module "secrets" {
  source                      = "./modules/secrets"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  base_name                   = module.vmss.base_name
  vnet_id                     = module.networking.vnet_id
  private_endpoint_subnet_id  = module.networking.private_endpoints_subnet_id
  keyvault_asg_id             = module.networking.keyvault_asg_id
  #app_gateway_cert            = var.app_gateway_certificate_base64
  #vmss_public_cert            = var.vmss_public_cert_base64
  #vmss_pfx                    = var.vmss_pfx_base64
 # keyvault_name               = module.monitoring.log_analytics_workspace_name
  app_gateway_certificate_base64 = var.app_gateway_certificate_base64
  vmss_public_cert_base64     = var.vmss_public_cert_base64
  vmss_pfx_base64             = var.vmss_pfx_base64
  tags = var.tags
  }


module "gateway" {
  source                  = "./modules/gateway"
  location                = var.location
  resource_group_name     = var.resource_group_name
  vnet_id                 = module.networking.vnet_id
  subnet_id               = module.networking.appgw_subnet_id
  base_name               = module.vmss.base_name
  ssl_cert_uri            = module.secrets.gateway_secret_uri
  trusted_root_cert_uri   = module.secrets.trusted_root_secret_uri
  public_ip_id            = module.networking.appgw_public_ip_id
  domain_name             = var.domain_name
  log_analytics_name      = module.monitoring.log_analytics_workspace_name
  keyvault_name           = module.secrets.keyvault_name
}

module "ilb" {
  source                  = "./modules/ilb"
  location                = var.location
  resource_group_name     = var.resource_group_name
  vnet_id                 = module.networking.vnet_id
  subnet_id               = module.networking.ilb_subnet_id
  base_name               = module.vmss.base_name
  zones                   = [1,2,3]
  log_analytics_name      = module.monitoring.log_analytics_workspace_name
}

module "olb" {
  source                  = "./modules/olb"
  location                = var.location
  resource_group_name     = var.resource_group_name
  base_name               = module.vmss.base_name
  zones                   = [1,2,3]
  log_analytics_name      = module.monitoring.log_analytics_workspace_name
}

module "vmss" {
  source                      = "./modules/vmss"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  vnet_id                     = module.networking.vnet_id
  frontend_subnet_id          = module.networking.frontend_subnet_id
  backend_subnet_id           = module.networking.backend_subnet_id
  ilb_id                      = module.ilb.ilb_id
  olb_id                      = module.olb.olb_id
  appgw_id                    = module.gateway.appgw_id
  log_analytics_name          = module.monitoring.log_analytics_workspace_name
  base_name                   = module.vmss.base_name
  domain_name                 = var.domain_name
  frontend_cloudinit_base64   = var.frontend_cloudinit_base64
  admin_password              = var.admin_password
  admin_security_principal_id = var.admin_security_principal_id
  admin_security_principal_type = var.admin_security_principal_type
  keyvault_name               = module.secrets.keyvault_name
  tags = var.tags
  vmss_pfx_secret_uri = module.vmss_pfx_secret_uri
  zones = var.zones
}

module "monitoring" {
  source              = "./modules/monitoring"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = var.tags
}

module "governance" {
  source              = "./modules/governance"
  location            = var.location
  resource_group_name = var.resource_group_name
}
