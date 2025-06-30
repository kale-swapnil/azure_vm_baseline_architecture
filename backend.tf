terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }
  backend "azurerm" {
    access_key = "add_access_key_here"
    resource_group_name  = "terraform_backend"
    storage_account_name = "terraformbaseline"
    container_name       = "backend"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
