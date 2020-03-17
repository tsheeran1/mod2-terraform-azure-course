# demo instance
resource "azurerm_linux_virtual_machine" "demo-instance-1" {
  name                  = "${var.prefix}-vm"
  resource_group_name   = azurerm_resource_group.demo.name
  location              = var.location
  size                  = "Standard_A1_v2"
  admin_username        = "demo"
  network_interface_ids = [azurerm_network_interface.demo-instance-1.id]

disable_password_authentication = true
admin_ssh_key {
  username    = "demo"
  public_key  = file("~/.ssh/demo-key.pub")
}

os_disk {
  caching              = "ReadWrite"
  storage_account_type = "Standard_LRS"
}

source_image_reference {
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "16.04-LTS"
  version   = "latest"
}
}

resource "azurerm_network_interface" "demo-instance-1" {
  name                      = "${var.prefix}-instance1"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.demo.name

  ip_configuration {
    name                           = "instance1"
    subnet_id                      = azurerm_subnet.demo-internal-1.id
    private_ip_address_allocation  = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.demo-instance-1.id
  }
}

# Need a NIC to Net Sec Group Association with V2
resource "azurerm_network_interface_security_group_association" "nic-1-allow-ssh" {
  network_interface_id          = azurerm_network_interface.demo-instance-1.id
  network_security_group_id     = azurerm_network_security_group.allow-ssh.id
}

resource "azurerm_public_ip" "demo-instance-1" {
    name                         = "instance1-public-ip"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.demo.name
    allocation_method            = "Dynamic"
}

resource "azurerm_application_security_group" "demo-instance-group" {
  name                = "internet-facing"
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name
}

resource "azurerm_network_interface_application_security_group_association" "demo-instance-group" {
  network_interface_id          = azurerm_network_interface.demo-instance-1.id
  application_security_group_id = azurerm_application_security_group.demo-instance-group.id
}

# demo instance 2
resource "azurerm_linux_virtual_machine" "demo-instance-2" {
  name                  = "${var.prefix}-vm-2"
  resource_group_name   = azurerm_resource_group.demo.name
  location              = var.location
  size                  = "Standard_A1_v2"
  admin_username        = "demo"
  network_interface_ids = [azurerm_network_interface.demo-instance-2.id]

disable_password_authentication = true
admin_ssh_key {
  username    = "demo"
  public_key  = file("~/.ssh/demo-key.pub")
}

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_network_interface" "demo-instance-2" {
  name                      = "${var.prefix}-instance2"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.demo.name

  ip_configuration {
    name                           = "instance2"
    subnet_id                      = azurerm_subnet.demo-internal-1.id
    private_ip_address_allocation  = "Dynamic"
  }
}

# Need a NIC to Net Sec Group Association with V2
resource "azurerm_network_interface_security_group_association" "nic-2-internal-facing" {
  network_interface_id          = azurerm_network_interface.demo-instance-2.id
  network_security_group_id     = azurerm_network_security_group.internal-facing.id
}

