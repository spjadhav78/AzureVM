provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "wintech" {
  name     = "wintech-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "wintech" {
  name                = "wintech-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.wintech.location
  resource_group_name = azurerm_resource_group.wintech.name
}

resource "azurerm_subnet" "wintech" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.wintech.name
  virtual_network_name = azurerm_virtual_network.wintech.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "wintech" {
  name                = "wintech-nic"
  location            = azurerm_resource_group.wintech.location
  resource_group_name = azurerm_resource_group.wintech.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.wintech.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "wintech" {
  name                = "wintech-machine"
  resource_group_name = azurerm_resource_group.wintech.name
  location            = azurerm_resource_group.wintech.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.wintech.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}