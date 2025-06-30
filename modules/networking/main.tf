resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.location}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.240.0.0/21"]
  tags                = var.tags
}

resource "azurerm_subnet" "frontend" {
  name                 = "snet-frontend"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.240.0.0/24"]
  # network_security_group_id = azurerm_network_security_group.frontend.id
}

# ... repeat for backend, ilb, appgw, privatelink, deploymentagent, bastion subnets

resource "azurerm_network_security_group" "bastion" {
  name                = "nsg-${var.location}-bastion"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_public_ip" "bastion" {
  name                = "pip-ab-${var.location}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
  zones               = var.zones
}

resource "azurerm_bastion_host" "this" {
  name                = "ab-${var.location}"
  resource_group_name = var.resource_group_name
  location            = var.location
  ip_configuration {
    name                 = "hub-subnet"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}
