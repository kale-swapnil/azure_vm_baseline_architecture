resource "azurerm_user_assigned_identity" "frontend" {
  name                = "id-vm-frontend"
  resource_group_name = var.resource_group_name
  location            = var.location
}
resource "azurerm_user_assigned_identity" "backend" {
  name                = "id-vm-backend"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# KeyVault role assignments for both identities
module "frontend_secrets_role" {
  source             = "../keyvault_role_assignment"
  role_definition_id = data.azurerm_role_definition.kv_secret_user.id
  principal_id       = azurerm_user_assigned_identity.frontend.principal_id
  keyvault_name      = var.keyvault_name
  resource_group_name = var.resource_group_name
}
module "frontend_reader_role" {
  source             = "../keyvault_role_assignment"
  role_definition_id = data.azurerm_role_definition.kv_reader.id
  principal_id       = azurerm_user_assigned_identity.frontend.principal_id
  keyvault_name      = var.keyvault_name
  resource_group_name = var.resource_group_name
}
# … same for backend identity

data "azurerm_role_definition" "kv_reader" {
  name = "21090545-7ca7-4776-b22c-e363652d74d2"
}
data "azurerm_role_definition" "kv_secret_user" {
  name = "4633458b-17de-408e-b874-0445c86b69e6"
}
data "azurerm_role_definition" "vm_admin_login" {
  name = "1c0163c0-47e6-4577-8991-ea5c82e286e4"
}

# VMSS frontend (Linux)
resource "azurerm_linux_virtual_machine_scale_set" "frontend" {
  name                = "vmss-frontend"
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones
  sku                 = "Standard_D4s_v3"
  instances           = 3
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.frontend.id]
  }
  extension {
  name                 = "CustomScript"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  auto_upgrade_minor_version = true
  protected_settings = {
    commandToExecute = "bash configure-nginx-frontend.sh"
    fileUris = [
      "scripts/configure-nginx-frontend.sh"
    ]
  }
}
  admin_username = "admin${substr(var.base_name,0,6)}"
  admin_password = var.admin_password
  custom_data    = var.frontend_cloudinit_base64
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
  }
  data_disk {
  lun                  = 0
  caching              = "None"
  create_option        = "Empty"
  disk_size_gb         = 4
  storage_account_type = "Standard_LRS"
}
  network_interface {
    name                           = "nic-frontend"
    primary                        = true
   # subnet_id                      = var.frontend_subnet_id
   # load_balancer_backend_address_pool_ids = [var.olb_id]
    #application_security_group_ids        = [data.azurerm_application_security_group.frontend.id]
    ip_configuration {
      name                          = "ipconfig-frontend"
      primary                       = true
  }

  # extension {
  #   name                 = "AADSSHLogin"
  #   publisher            = "Microsoft.Azure.ActiveDirectory"
  #   type                 = "AADSSHLoginForLinux"
  #   type_handler_version = "1.0"
  # }
  # … other extensions (KeyVaultForLinux, CustomScript, Monitoring, HealthExtension)
}
}


# VMSS backend (Windows) – similar using azurerm_windows_virtual_machine_scale_set

resource "azurerm_windows_virtual_machine_scale_set" "backend" {
  name                = "vmss-backend"
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = [1, 2, 3]
  sku = "Standard_E2s_v3"
  instances           = 3
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.backend.id]
  }
  admin_username = "admin${substr(var.base_name,0,6)}"
  admin_password = var.admin_password

  upgrade_mode = "Manual"
  platform_fault_domain_count = 1
  single_placement_group      = false
  zone_balance                = false


  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-smalldisk"
    version   = "latest"
  }




   os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
  }

  data_disk {
    lun                  = 0
    caching              = "None"
    create_option        = "Empty"
    disk_size_gb         = 4
    #delete_option        = "Delete"
    storage_account_type = "Premium_ZRS"
  }


  network_interface {
    name    = "nic-backend"
    primary = true
    network_security_group_id = null

    ip_configuration {
      name      = "ipconfig1"
      subnet_id = var.backend_subnet_id
      primary   = true

      application_security_group_ids = [
        data.azurerm_application_security_group.backend.id
      ]

      load_balancer_backend_address_pool_ids = [
        "${var.ilb_id}/backendAddressPools/apiBackendPool",
        "${var.olb_id}/backendAddressPools/outboundBackendPool"
      ]
    }
  }

  extension {
    name                 = "KeyVaultForWindows"
    publisher            = "Microsoft.Azure.KeyVault"
    type                 = "KeyVaultForWindows"
    type_handler_version = "3.0"
    auto_upgrade_minor_version = true
    settings = jsonencode({
      secretsManagementSettings = {
        observedCertificates = [{
          certificateStoreName     = "MY"
          certificateStoreLocation = "LocalMachine"
          keyExportable            = true
          url                      = var.vmss_pfx_secret_uri
          accounts                 = ["Network Service", "Local Service"]
        }]
        linkOnRenewal     = true
        pollingIntervalInS = 3600
      }
    })
  }

  extension {
    name                 = "CustomScriptExtension"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.10"
    auto_upgrade_minor_version = true
    protected_settings = {
      commandToExecute = "powershell -ExecutionPolicy Unrestricted -File configure-nginx-backend.ps1"
      fileUris = [
        "scripts/configure-nginx-backend.ps1"
      ]
    }
    provision_after_extensions = ["KeyVaultForWindows"]
  }

  extension {
    name                 = "AzureMonitorWindowsAgent"
    publisher            = "Microsoft.Azure.Monitor"
    type                 = "AzureMonitorWindowsAgent"
    type_handler_version = "1.14"
    auto_upgrade_minor_version = true
    settings = jsonencode({
      authentication = {
        managedIdentity = {
          "identifier-name"  = "mi_res_id"
          "identifier-value" = azurerm_user_assigned_identity.backend.id
        }
      }
    })
  }

  extension {
    name                 = "DependencyAgentWindows"
    publisher            = "Microsoft.Azure.Monitoring.DependencyAgent"
    type                 = "DependencyAgentWindows"
    type_handler_version = "9.10"
    auto_upgrade_minor_version = true
   # enable_automatic_upgrade   = true
    provision_after_extensions = ["AzureMonitorWindowsAgent"]
    settings = jsonencode({
      enableAMA = true
    })
  }

  extension {
    name                 = "ApplicationHealthWindows"
    publisher            = "Microsoft.ManagedServices"
    type                 = "ApplicationHealthWindows"
    type_handler_version = "1.0"
    auto_upgrade_minor_version = true
    provision_after_extensions = ["CustomScriptExtension"]
    settings = jsonencode({
      protocol           = "https"
      port               = 443
      requestPath        = "/favicon.ico"
      intervalInSeconds  = 5
      numberOfProbes     = 3
    })
  }

#   boot_diagnostics {
#     enabled = true
#     enabled = true
#   }

  tags = var.tags

  depends_on = [
    azurerm_user_assigned_identity.backend,
    module.keyvault_role_assignment_backend_reader,
    module.keyvault_role_assignment_backend_secret,
    module.monitoring,
    data.azurerm_application_security_group.backend
  ]
}


resource "azurerm_monitor_diagnostic_setting" "vmss" {
  name                       = "default"
  target_resource_id         = azurerm_linux_virtual_machine_scale_set.frontend.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.this.id
}

data "azurerm_log_analytics_workspace" "this" {
  name                = var.log_analytics_name
  resource_group_name = var.resource_group_name
}
