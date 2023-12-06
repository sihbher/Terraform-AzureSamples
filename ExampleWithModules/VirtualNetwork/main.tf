

//Create a Virtual Network
resource "azurerm_virtual_network" "vnet1" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "subnets_list" {
  for_each             = var.subnets
  name                 = each.value.name
  address_prefixes     = each.value.address_prefixes
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
}

//Create the NSGs for each subnet
resource "azurerm_network_security_group" "NSGs" {
  for_each            = var.subnets
  name                = "${each.value.name}-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location
}

//Create NSGs association for each subnet
//AUN NO SE COMO HACER ESTO
# resource "azurerm_subnet_network_security_group_association" "subnet-NSGs" {
#   for_each                  = resource.azurerm_subnet.subnets_list
#   subnet_id                 = each.value.id
#   network_security_group_id = resource.azurerm_network_security_group.NSGs[index(resource.azurerm_subnet.subnets_list, "${each.value.name}-nsg")].id


# }

// resource.azurerm_network_security_group.NSGs[index(resource.azurerm_subnet.subnets.*.value.id, "${each.value.name}-nsg")].id
