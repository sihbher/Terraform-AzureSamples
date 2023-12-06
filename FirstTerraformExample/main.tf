terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.72.0"
    }
  }
}

resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}

provider "azurerm" {
  features {}
}


// Create a resource group
resource "azurerm_resource_group" "RG" {
  name     = var.rg_name
  location = var.location
  tags = {
    environment = "Test",
    delete      = "yes"
  }
}


//********************************* Create a Storage Account *********************************//
resource "azurerm_storage_account" "SA1" {
  name                     = "${lower(var.storage_account_basename)}${random_string.random.result}"
  resource_group_name      = azurerm_resource_group.RG.name
  location                 = azurerm_resource_group.RG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  public_network_access_enabled = false
  allow_nested_items_to_be_public = false
  tags = {
    environment = "Test",
    delete      = "yes"
  }
}



//Create a security group
resource "azurerm_network_security_group" "NSG" {
  name                = "WSPLUS-IaaS-NSG"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  tags = {
    environment = "Test",
    delete      = "yes"
  }
}

//Create a Virtual Network
resource "azurerm_virtual_network" "VNET" {
  name                = "WSPLUS-IaaS-VNET"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  tags = {
    environment = "Test",
    delete      = "yes"
  }
}

//Create the FrontEnd subnet
resource "azurerm_subnet" "FrontEnd" {
  name                 = "FrontEnd-Subnet"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VNET.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "FrontEnd-NSG" {
  subnet_id                 = azurerm_subnet.FrontEnd.id
  network_security_group_id = azurerm_network_security_group.NSG.id
}


//Create the BackEnd subnet
resource "azurerm_subnet" "BackEnd-Subnet" {
  name                 = "BackEnd-Subnet"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VNET.name
  address_prefixes     = ["10.10.2.0/24"]
}

//Create the Bastion subnet
resource "azurerm_subnet" "Bastion-Subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VNET.name
  address_prefixes     = ["10.10.3.0/26"]
}

//Create a Public IP address for Bastion
resource "azurerm_public_ip" "Bastion-PIP" {
  name                = "Bastion-PIP"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "Bastion-Host" {
  name                = "Bastion"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  sku                 = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.Bastion-Subnet.id
    public_ip_address_id = azurerm_public_ip.Bastion-PIP.id
  }
}


//*********************** Create a Virtual Machine ***********************//
//First, create a network interface
resource "azurerm_network_interface" "vm1-NIC" {
  name                = "vm-frontend-NIC"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "vm-frontend-NIC-configuration"
    subnet_id                     = azurerm_subnet.FrontEnd.id
    private_ip_address_allocation = "Dynamic"
  }
}

//Create a virtual machine
resource "azurerm_windows_virtual_machine" "VM1" {
  name                = "vm-frontend-001"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  size                = "Standard_D2_v5"
  admin_username      = "LabAdmin"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.vm1-NIC.id,
  ]

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "gc" {
  name                       = "AzurePolicyforWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.VM1.id
  publisher                  = "Microsoft.GuestConfiguration"
  type                       = "ConfigurationforWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = "true"

  depends_on = [
    azurerm_windows_virtual_machine.VM1
  ]
}
