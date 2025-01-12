resource "azurerm_public_ip" "vpn" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.rg.location
  name                = "vpn-pub-ip"
  domain_name_label   = "mat-${local.vpn_vm_name}-${local.suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(
    azurerm_resource_group.rg.tags,
    {}
  )
}

resource "azurerm_network_security_group" "vpn_sg" {
  location            = azurerm_resource_group.rg.location
  name                = "vpn-vm-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  tags = merge(
    azurerm_resource_group.rg.tags,
    {}
  )
}

resource "azurerm_network_security_rule" "vpn_nsg_ssh" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "SSH"
  network_security_group_name = azurerm_network_security_group.vpn_sg.name
  priority                    = 300
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.rg.name
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "vpn_nsg_ipsec1" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "IPSEC1"
  network_security_group_name = azurerm_network_security_group.vpn_sg.name
  priority                    = 400
  protocol                    = "Udp"
  resource_group_name         = azurerm_resource_group.rg.name
  destination_address_prefix  = "*"
  destination_port_range      = "500"
  source_address_prefix       = "*"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "vpn_nsg_ipsec2" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "IPSEC2"
  network_security_group_name = azurerm_network_security_group.vpn_sg.name
  priority                    = 500
  protocol                    = "Udp"
  resource_group_name         = azurerm_resource_group.rg.name
  destination_address_prefix  = "*"
  destination_port_range      = "4500"
  source_address_prefix       = "*"
  source_port_range           = "*"
}

resource "azurerm_network_interface" "vpn_vm_main" {
  location            = azurerm_resource_group.rg.location
  name                = local.vpn_vm_name
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.vpn.id
    public_ip_address_id = azurerm_public_ip.vpn.id
  }
}

resource "azurerm_network_interface_security_group_association" "vpn_vm_main_nsg" {
  network_interface_id      = azurerm_network_interface.vpn_vm_main.id
  network_security_group_id = azurerm_network_security_group.vpn_sg.id
}

resource "azurerm_linux_virtual_machine" "vpn_vm" {
  admin_username      = local.admin_username
  location            = azurerm_resource_group.rg.location
  name                = local.vpn_vm_name
  network_interface_ids = [
    azurerm_network_interface.vpn_vm_main.id,
  ]
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B1s"
  tags = merge(
    azurerm_resource_group.rg.tags,
    {}
  )
  identity {
    type = "SystemAssigned"
  }
  admin_ssh_key {
    public_key = local.ssh_public_key
    username   = local.admin_username
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 40
  }
  source_image_reference {
    offer     = "ubuntu-24_04-lts"
    publisher = "canonical"
    sku       = "server"
    version   = "latest"
  }
}
