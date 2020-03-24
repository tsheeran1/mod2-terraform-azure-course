provider "azurerm" {
  version = "~>2.0"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "demo" {
  name     = "sql-demo"
  location = var.location
}
