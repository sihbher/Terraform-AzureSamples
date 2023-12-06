terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.72.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "ResourceGroup" {
  source                  = "./ResourceGroup"
  resource_group_basename = "WSPLUS-IaaS-Terraform"
  location                = "eastus"
}

module "StorageAccount" {
  source                           = "./StorageAccount"
  resource_group_name              = module.ResourceGroup.resource_group.name
  location                         = module.ResourceGroup.resource_group.location
  storage_account_basename         = "wsplussa"
  storage_account_tier             = "Standard"
  storage_account_replication_type = "LRS"
  tags                             = module.ResourceGroup.resource_group.tags
}


module "VirtualNetwork" {
  source              = "./VirtualNetwork"
  resource_group_name = module.ResourceGroup.resource_group.name
  location            = module.ResourceGroup.resource_group.location
  vnet_name           = "wsplusvnet"
  address_space       = ["10.10.0.0/16"]
  subnets = {
    FrontEnd = {
      name             = "FrontEnd-Subnet"
      address_prefixes = ["10.10.1.0/24"]
    },
    BackEnd = {
      name             = "BackEnd-Subnet"
      address_prefixes = ["10.10.2.0/24"]
    }
  }
}