terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
  number  = false
}

//********************************* Create a Storage Account *********************************//
resource "azurerm_storage_account" "SA1" {
  name                     = "${lower(var.storage_account_basename)}${random_string.random.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  tags                     = var.tags
}