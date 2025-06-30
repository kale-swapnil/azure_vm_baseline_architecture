# ========================
# Environment Configuration
# ========================
environment              = "dev"
location                 = "centralindia"
resource_group_name      = "rg-iaas-baseline"

# ========================
# Terraform Backend State
# ========================
# backend_rg_name          = "rg-terraform-state"
# backend_sa_name          = "tfstateeastus2"
# backend_container_name   = "terraform-state"
# backend_key_prefix       = "iac/iaas-baseline"

# ========================
# Network & Application Setup
# ========================
domain_name              = "domainname.com"
frontend_cloudinit_base64 = filebase64("scripts/cloudconfig.yaml")

# ========================
# Secrets & Certificates
# ========================
app_gateway_certificate_base64             = filebase64("certs/appgw-cert.pfx")
vmss_public_cert_base64                    = filebase64("certs/vmss-webserver.crt")
vmss_pfx_base64                            = filebase64("certs/vmss-webserver.pfx")

# ========================
# Admin Identity & Access
# ========================
admin_password                 = "ReplaceWithStrongPassword123!"  # Bicep `adminPassword`
admin_security_principal_id   = "11111111-2222-3333-4444-555555555555"  # Replace with actual ObjectId
admin_security_principal_type = "User"  # Default from Bicep
