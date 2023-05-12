provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "wintech" {
  name     = "wintech-resource-group"
  location = "East US"
}

resource "azurerm_virtual_network" "wintech" {
  name                = "wintech-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.wintech.location
  resource_group_name = azurerm_resource_group.wintech.name
}

resource "azurerm_subnet" "wintech" {
  name                 = "wintech-subnet"
  address_prefix       = "10.0.1.0/24"
  virtual_network_name = azurerm_virtual_network.wintech.name
  resource_group_name  = azurerm_resource_group.wintech.name
}

resource "azurerm_network_security_group" "wintech" {
  name                = "wintech-nsg"
  location            = azurerm_resource_group.wintech.location
  resource_group_name = azurerm_resource_group.wintech.name
}

resource "azurerm_network_interface" "wintech" {
  name                = "wintech-nic"
  location            = azurerm_resource_group.wintech.location
  resource_group_name = azurerm_resource_group.wintech.name

  ip_configuration {
    name                          = "wintech-ipconfig"
    subnet_id                     = azurerm_subnet.wintech.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = null
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_public_ip" "wintech" {
  name                = "wintech-public-ip"
  location            = azurerm_resource_group.wintech.location
  resource_group_name = azurerm_resource_group.wintech.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_storage_account" "wintech" {
  name                     = "wintechstorageaccount"
  resource_group_name      = azurerm_resource_group.wintech.name
  location                 = azurerm_resource_group.wintech.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_machine" "wintech" {
  name                  = "wintech-vm"
  location              = azurerm_resource_group.wintech.location
  resource_group_name   = azurerm_resource_group.wintech.name
  network_interface_ids = [azurerm_network_interface.wintech.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "wintech-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "wintech-vm"
    admin_username = "adminuser"

    admin_password = "P@ssw0rd1234!"
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface_security_group_association" "wintech" {
  network_interface_id      = azurerm_network_interface.wintech.id
  network_security_group_id = azurerm_network_security_group.wintech.id
}