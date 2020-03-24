# demo instance
resource "azurerm_linux_virtual_machine" "demo-instance" {
  name                              = "${var.prefix}-vm"
  resource_group_name               = azurerm_resource_group.demo.name
  location                          = var.location
  size                              = "Standard_A1_v2"
  admin_username                    = "demo"
  network_interface_ids             = ["${azurerm_network_interface.demo-nic.id}"]
  disable_password_authentication   = true
  admin_ssh_key {
    username        = "demo"
    public_key      = file("~/.ssh/demo-key.pub")
  }

  os_disk {
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
    }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "demo-nic" {
  name                      = "${var.prefix}-instance1"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.demo.name

  ip_configuration {
    name                          = "instance1"
    subnet_id                     = azurerm_subnet.demo-internal-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.demo-instance.id
  }
}

resource "azurerm_network_interface_security_group_association" "demo-nic-allowssh" {
  network_interface_id        = azurerm_network_interface.demo-nic.id
  network_security_group_id   = azurerm_network_security_group.allow-ssh.id
}


resource "azurerm_public_ip" "demo-instance" {
  name                = "instance1-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name
  allocation_method   = "Dynamic"
}
