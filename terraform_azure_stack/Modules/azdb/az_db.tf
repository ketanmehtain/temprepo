data "azurerm_resource_group" "rg" {
  name     = var.resourcegroupname
}

resource "azurerm_postgresql_flexible_server" "example" {
  name                          = "lloyds-psql-02"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  version                       = "16"
  delegated_subnet_id           = var.db_subnet
  private_dns_zone_id           = azurerm_private_dns_zone.example.id
  public_network_access_enabled = false
  administrator_login           = "psqladmin"
  administrator_password        = "psqladmin"
  zone                          = "1"

  storage_mb   = 32768
  storage_tier = "P30"

  sku_name   = "GP_Standard_D2s_v3"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.example]
  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "azurerm_postgresql_flexible_server_database" "accountsdb" {
  name      = "accounts-db"
  server_id = azurerm_postgresql_flexible_server.example.id
  collation = "en_US.utf8"
  charset   = "utf8"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_postgresql_flexible_server_database" "ledgerdb" {
  name      = "ledger-db"
  server_id = azurerm_postgresql_flexible_server.example.id
  collation = "en_US.utf8"
  charset   = "utf8"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_private_dns_zone" "example" {
  name                = "lloyds.postgres.database.azure.com"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "lloydsVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = var.azurerm_virtual_network_id
  resource_group_name   = data.azurerm_resource_group.rg.name
  registration_enabled  = false
  depends_on = [azurerm_private_dns_zone.example]
}

resource "azurerm_private_dns_a_record" "postgresql_dns_record" {
  name                = "postgresql"
  zone_name           = azurerm_private_dns_zone.example.name
  resource_group_name = data.azurerm_resource_group.rg.name
  ttl                 = 300
  records             = ["10.0.2.4"]

  depends_on = [azurerm_private_dns_zone_virtual_network_link.example]
}