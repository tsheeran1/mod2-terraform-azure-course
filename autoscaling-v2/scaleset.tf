resource "azurerm_linux_virtual_machine_scale_set" "demo" {
  name                = "mytestscaleset-1"                # Name of the scaleset in Azure
  resource_group_name = azurerm_resource_group.demo.name  # resource group to put the SS in
  location            = var.location                      # region
  sku                 = "Standard_A1_V2"                  # what type (sku) of instance?
  instances           = 1                                 # how many to start?
  admin_username      ="demo"                             # name of admin user
  computer_name_prefix = "demo"                           # prefix for each instance name

  ### Install and Launch Nginx on each instance ###
  custom_data          = base64encode("#!/bin/bash\n\napt-get update && apt-get install -y nginx && systemctl enable nginx && systemctl start nginx")

#### Which Availability Zones do we want VMs in? ####
  zones           = var.zones

#### Only allow SSH with private key ####
  disable_password_authentication = true
  admin_ssh_key {
    username    = "demo"
    public_key  = file("~/.ssh/demo-key.pub")
  }

#### What OS image to we want? ####
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

### Describe our OS disk ####
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

#### Add a data disk to each instance  ###
  data_disk {
    lun                   = 0
    caching               = "ReadWrite"
    storage_account_type  = "Standard_LRS"
    disk_size_gb          = 10
  }


#### Describe our NIC ####
  network_interface {
    name              = "demo-network-interface"                                                    # Name of NIC in Azure
    primary           = true                                                                        # this is the primary (only) NIC
    ip_configuration {                                                                              # Describe the IP config
      name                                   = "IPConfiguration"                                    
      primary                                = true                                                 # primary IP for this NIC
      subnet_id                              = azurerm_subnet.demo-subnet-1.id                      # The subnet we are on
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]         # reference to the backend address pool defined for the lb
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lbnatpool.id]                   # reference to the nat pool defined for the lb
    }
    network_security_group_id                = azurerm_network_security_group.demo-instance.id      # connect a network secruity group to the NIC
  }

#### Enable Rolling Upgrades #####
  upgrade_mode =    "Rolling"
  health_probe_id = azurerm_lb_probe.demo.id

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }
}
