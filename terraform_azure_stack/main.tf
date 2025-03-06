data "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
}

module "network" {
    source = "./modules/network"
    resourcegroupname = var.resource_group_name
    resourcegrouplocation = data.azurerm_resource_group.rg.location
    virtual_network_name = var.virtual_network_name
    subnet_name = var.subnet_name
    address_space = var.address_space
    subnet_prefix = var.subnet_prefix
}

module "virtualmachine" {
    source = "./modules/virtualmachine"
    subnet_id = module.network.subnet_id
    public_ip_name = var.public_ip_name
    resourcegroupname = var.resource_group_name
    resourcegrouplocation = data.azurerm_resource_group.rg.location
    network_interface_name = var.network_interface_name
    virtual_machine_name = var.virtual_machine_name
    vm_size = var.vm_size
    admin_username      = var.admin_username
    admin_password      = var.admin_password
    depends_on = [module.network, module.azdb]
}

module "azdb" {
  source = "./Modules/azdb"
  db_subnet = module.network.db_subnet
  virtual_network_name = var.virtual_network_name
  resourcegroupname = var.resource_group_name
  azurerm_virtual_network_id = module.network.azurerm_virtual_network_id
  depends_on = [module.network]
}

# module "migrole" {
#   source = "./Modules/migrole"
# }