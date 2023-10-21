terraform {
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.12.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "89f255bf-33e7-4aa7-a855-f95bd174329d"
  client_id       = "0b463b4a-2371-4daa-95eb-2aec1416718c"
  client_secret   = "uXC8Q~kybEZ1Ta8BJD2oG9IvRaXV6FsfSU23cbm4"
  tenant_id       = "95e72c78-d792-406a-b53d-89192dc23de3"
}

 resource "azurerm_resource_group" "azurerm" {
  name     = "Terraform"
  location = "east US"
}
resource "azurerm_virtual_network" "vnet" {
  name                = "terraformNetwork"
  location            = azurerm_resource_group.azurerm.location
  resource_group_name = azurerm_resource_group.azurerm.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}
resource "azurerm_subnet" "subnet" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.azurerm.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_network_security_group" "NSG" {
  name                = "TestSecurityGroup"
  location            = azurerm_resource_group.azurerm.location
  resource_group_name = azurerm_resource_group.azurerm.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}
resource "azurerm_public_ip" "publicip" {
  name                = "TestPublicIp"
  resource_group_name = azurerm_resource_group.azurerm.name
  location            = azurerm_resource_group.azurerm.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}
resource "azurerm_network_interface" "nic" {
  name                = "Test-nic"
  location            = azurerm_resource_group.azurerm.location
  resource_group_name = azurerm_resource_group.azurerm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_virtual_machine" "main" {
  name                  = "Terraform-VM"
  location              = azurerm_resource_group.azurerm.location
  resource_group_name   = azurerm_resource_group.azurerm.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version ="latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "Linux (ubuntu 22.04)"
    admin_username = "lohita"
    admin_password = "Littlehearts79"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}
