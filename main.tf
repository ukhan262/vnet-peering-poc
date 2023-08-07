provider "azurerm" {
  features {}
}


resource "azurerm_virtual_network" "vnet1" {
  name = "vnet-1-peer-test"
  resource_group_name = "rg-arun"
  location = "eastus2"
  address_space = [ "20.0.0.0/24" ]
}

resource "azurerm_virtual_network" "vnet2" {
  name = "vnet-2-peer-test"
  resource_group_name = "rg-arun"
  location = "eastus2"
  address_space = [ "30.0.0.0/24"]
}

resource "azurerm_virtual_network_peering" "example-1" {
  name                      = "peer1to2"
  resource_group_name = "rg-arun"
  virtual_network_name      = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id = azurerm_virtual_network.vnet2.id
}

resource "azurerm_virtual_network_peering" "example-2" {
  name                      = "peer2to1"
  resource_group_name = "rg-arun"
  virtual_network_name      = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id = azurerm_virtual_network.vnet1.id
}