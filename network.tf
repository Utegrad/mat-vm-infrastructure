resource "azurerm_virtual_network" "vm_vnet" {
  address_space = ["10.124.0.0/21"]
  location            = azurerm_resource_group.rg.location
  name                = "Web-VM-Network"
  resource_group_name = azurerm_resource_group.rg.name
  tags = merge(
    azurerm_resource_group.rg.tags,
    {}
  )
}

# Route VM traffic to the Internet egress traffic through a common public IP address
resource "azurerm_subnet" "vpn" {
  address_prefixes = ["10.124.0.0/27"]
  name                 = "vpn"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vm_vnet.name
}

resource "azurerm_subnet" "web_vm_subnet" {
  name = "web-vms"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vm_vnet.name
  address_prefixes = ["10.124.1.0/24"]
}


resource "azurerm_subnet" "db_vm_subnet" {
  name = "db-vms"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vm_vnet.name
  address_prefixes = ["10.124.2.0/24"]
}

resource "azurerm_network_security_group" "web_vm_nsg" {
  location            = azurerm_resource_group.rg.location
  name                = "web-vm-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  tags = merge(
    azurerm_resource_group.rg.tags,
    {}
  )
}

resource "azurerm_network_security_rule" "web_vm_nsg_rule_ssh" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "SSH"
  network_security_group_name = azurerm_network_security_group.web_vm_nsg.name
  priority                    = 300
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.rg.name
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "web_vm_nsg_rule_http" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "HTTP"
  network_security_group_name = azurerm_network_security_group.web_vm_nsg.name
  priority                    = 400
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.rg.name
  destination_address_prefix  = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  source_port_range           = "*"
}

resource "azurerm_network_security_rule" "web_vm_nsg_rule_https" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "HTTPS"
  network_security_group_name = azurerm_network_security_group.web_vm_nsg.name
  priority                    = 500
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.rg.name
  destination_address_prefix  = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  source_port_range           = "*"
}

