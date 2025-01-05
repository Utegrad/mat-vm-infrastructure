locals {
  web_vm_name = "web01"
}

resource "azurerm_public_ip" "web_pub_ip" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.rg.location
  name                = "web-pub-ip"
  resource_group_name = azurerm_resource_group.rg.name
  domain_name_label = "mat-${local.web_vm_name}-${local.suffix}"
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(
    azurerm_resource_group.rg.tags,
    {}
  )
}

resource "azurerm_network_interface" "web_vm_main" {
  location            = azurerm_resource_group.rg.location
  name                = local.web_vm_name
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.web_vm_subnet.id
  }
}
