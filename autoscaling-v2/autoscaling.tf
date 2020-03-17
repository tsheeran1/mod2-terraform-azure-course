resource "azurerm_monitor_autoscale_setting" "example" {
  name                = "demo-autoscaling"
  resource_group_name = azurerm_resource_group.demo.name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.demo.id   #  Which SS do we want to monitor?

  profile {                                 # Use this profile for autoscaling
    name = "defaultProfile"

    capacity {
      default = 2                           # if metrics unavailable ensure at least 2 VMs are up
      minimum = 2                           # don't drop below 2
      maximum = 4                           # don't scale to more than 4
    }

    rule {
      metric_trigger {                          # When average CPU across the scale set goes above 40%  
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.demo.id
        time_grain         = "PT1M"             # Collect metric every minute
        statistic          = "Average"          # Average across all instances
        time_window        = "PT5M"             # Collect data for 5 minutes
        time_aggregation   = "Average"          # Average over past 5 minutes
        operator           = "GreaterThan"
        threshold          = 40
      }

      scale_action {                          # Do the following when above rule is triggered
        direction = "Increase"                # Increase number of VMs (scale up)
        type      = "ChangeCount"             # Change the number of VMs
        value     = "1"                       # By 1 VM
        cooldown  = "PT1M"                    # Wait at least 1 minute before doing another scale action
      }
    }

    rule {                                      # When average CPU across the scale set goes below 10%
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.demo.id
        time_grain         = "PT1M"             # Collect every minute
        statistic          = "Average"          # Average every minute data across all VMs
        time_window        = "PT5M"             # Collect 5 minutes worth of data at 1 minute intervals
        time_aggregation   = "Average"          # Average across the 5 minutes
        operator           = "LessThan"
        threshold          = 10
      }

      scale_action {                          # Do the following when above rule is triggered
        direction = "Decrease"                # reduce number of VMs (scale down)
        type      = "ChangeCount"             # change the count (vs a % or set a specific number)
        value     = "1"                       # by 1
        cooldown  = "PT1M"                    # wait at least a minute between actions
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
  #    send_to_subscription_co_administrator = true
  #    custom_emails                         = ["admin@yourdomain.com"]
    }
  }
}
