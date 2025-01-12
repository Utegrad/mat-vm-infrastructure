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
    public_ip_address_id = azurerm_public_ip.web_pub_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "web_vm_main_nsg" {
  network_interface_id      = azurerm_network_interface.web_vm_main.id
  network_security_group_id = azurerm_network_security_group.web_vm_nsg.id
}

resource "azurerm_managed_disk" "web_vm_data" {
  create_option        = "Empty"
  location             = azurerm_resource_group.rg.location
  name                 = "data1-${local.web_vm_name}-${local.suffix}"
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "StandardSSD_LRS"
  disk_size_gb         = 20
}

resource "azurerm_linux_virtual_machine" "nginx_vm" {
  admin_username      = local.admin_username
  location            = azurerm_resource_group.rg.location
  name                = "${local.web_vm_name}-nginx-${local.suffix}"
  network_interface_ids = [
    azurerm_network_interface.web_vm_main.id,
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

resource "azurerm_virtual_machine_data_disk_attachment" "web_vm_data_disk" {
  managed_disk_id    = azurerm_managed_disk.web_vm_data.id
  virtual_machine_id = azurerm_linux_virtual_machine.nginx_vm.id
  lun                = "10"
  caching            = "ReadWrite"
}
