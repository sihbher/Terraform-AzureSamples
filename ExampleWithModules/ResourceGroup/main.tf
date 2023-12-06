// Create a resource group
resource "azurerm_resource_group" "RG" {
  name     = "${var.resource_group_basename}-RG"
  location = var.location
  tags     = var.tags
}