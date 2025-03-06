output "subnet_id" {
  value       = azurerm_subnet.subnet.id
  description = "subnet id"
}

output "db_subnet" {
  value       = azurerm_subnet.db_subnet.id
  description = "db subnet id"
}

output "azurerm_virtual_network_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "vnet id"
}