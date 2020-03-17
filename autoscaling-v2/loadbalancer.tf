resource "azurerm_lb" "demo" {
  name                = "demo-loadbalancer"
  resource_group_name = azurerm_resource_group.demo.name
  location            = var.location
  sku                 = length(var.zones) == 0 ? "Basic" : "Standard" # Basic is free, but doesn't support Availability Zones
  frontend_ip_configuration {                             # Give the lb a public IP
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.demo.id
  }
}

resource "azurerm_public_ip" "demo" {
  name                = "demo-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name
  allocation_method   = "Static"
  domain_name_label   = azurerm_resource_group.demo.name
  sku                 = length(var.zones) == 0 ? "Basic" : "Standard"
}

### Create a backend pool so the scale set can reference  ####
resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = azurerm_resource_group.demo.name
  loadbalancer_id     = azurerm_lb.demo.id
  name                = "BackEndAddressPool"
}

###Create a NAT pool to mapp a port range from the LB to ports on the backend VMs  ####
resource "azurerm_lb_nat_pool" "lbnatpool" {
  resource_group_name            = azurerm_resource_group.demo.name
  name                           = "ssh"
  loadbalancer_id                = azurerm_lb.demo.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}


### Create a health check for the VMs  ####
resource "azurerm_lb_probe" "demo" {
  resource_group_name = azurerm_resource_group.demo.name
  loadbalancer_id     = azurerm_lb.demo.id
  name                = "http-probe"
  protocol            = "Http"
  request_path        = "/"
  port                = 80
}

### A rule allowing traffig to port 80 on lb to continue to port 80 on any of the SS instances (Backend pool)####
resource "azurerm_lb_rule" "demo" {
  resource_group_name            = azurerm_resource_group.demo.name
  loadbalancer_id                = azurerm_lb.demo.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.demo.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
}

