terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0.0, <5.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">3.0.0, <4.0.0"
    }
  }
  backend "azurerm" {
    tenant_id            = "3856e096-c28a-4cd5-b217-5dd1b1e08725"
    subscription_id      = "d456383e-ed3c-46f6-b745-e8cf0d85029f"
    resource_group_name  = "DefaultResources"
    storage_account_name = "terraformstaten01"
    container_name       = "vmstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  subscription_id = "d456383e-ed3c-46f6-b745-e8cf0d85029f"
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "WebServices"
  location = "westus2"
  tags = {
    company     = "MAT"
    status      = "in-use"
    managed_by  = "Terraform"
  }
}

resource "random_id" "rg" {
  keepers     = { resource_group = azurerm_resource_group.rg.name }
  byte_length = 8
}

