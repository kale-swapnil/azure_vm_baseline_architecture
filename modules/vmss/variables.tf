variable "location"                    { type = string }
variable "resource_group_name"         { type = string }
variable "vnet_id"                     { type = string }
variable "frontend_subnet_id"          { type = string }
variable "backend_subnet_id"           { type = string }
variable "ilb_id"                      { type = string }
variable "olb_id"                      { type = string }
variable "appgw_id"                    { type = string }
variable "log_analytics_name"          { type = string }
variable "base_name"                   { type = string }
variable "domain_name"                 { type = string }
variable "frontend_cloudinit_base64"   { type = string }
variable "admin_password"              { type = string }
variable "admin_security_principal_id" { type = string }
variable "admin_security_principal_type"{ type = string }
variable "keyvault_name"               { type = string }
variable "zones"                      { type = list(number) }
variable "tags"                        { type = map(string) }
variable "vmss_pfx_secret_uri" {
  type        = string
  description = "URI of the Key Vault secret containing the VMSS PFX certificate"
  
}
