variable "environment" {
  description = "Deployment environment (eg dev/test/prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "centralindia"
}

variable "resource_group_name" {
  description = "Name of the resource group to deploy into"
  type        = string
}

# Backend state config (pre-create RG/SA/container or point at existing)
# variable "backend_rg_name"       { type = string }
# variable "backend_sa_name"       { type = string }
# variable "backend_container_name"{ type = string }
# variable "backend_key_prefix"{ 
#   type = string
#   default = "terraform" 
#   }

# Security inputs
variable "app_gateway_certificate_base64" { type = string }
variable "vmss_public_cert_base64"        { type = string }
variable "vmss_pfx_base64"                { type = string }
variable "admin_password"                 { type = string }
variable "admin_security_principal_id"    { type = string }
variable "admin_security_principal_type"  { 
  type = string 
  default = "User" 
  }

variable "domain_name" { 
  type = string 
 #default = "domainname.com" 
  }
variable "frontend_cloudinit_base64" { type = string }

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "zones" {
  description = "Availability zones to use for resources"
  type        = list(number)
  default     = [1, 2, 3] 
}
