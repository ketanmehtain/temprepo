provider "azurerm" {
  features {}
}

data "azuread_client_config" "current" {}

data "azurerm_subscription" "current" {}

# 1️⃣ Register an App in Azure AD
resource "azuread_application" "migrate_app" {
  display_name = "MigrateToVMsApp"
  owners = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "migrate_sp" {
  client_id = azuread_application.migrate_app.client_id
  owners = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "migrate_sp_password" {
  service_principal_id = azuread_service_principal.migrate_sp.id
}

# 2️⃣ Define Custom Role for Migrate to Virtual Machines Service
resource "azurerm_role_definition" "migrate_custom_role" {
  name        = "MigrateToVMsRole"
  scope       = "/subscriptions/${var.subscription_id}"
  description = "Custom role for Migrate to Virtual Machines Service"

  permissions {
    actions = [
        "Microsoft.Resources/subscriptions/resourceGroups/write",
        "Microsoft.Resources/subscriptions/resourceGroups/read",
        "Microsoft.Resources/subscriptions/resourceGroups/delete",
        "Microsoft.Compute/virtualMachines/read",
        "Microsoft.Compute/virtualMachines/write",
        "Microsoft.Compute/virtualMachines/deallocate/action",
        "Microsoft.Compute/disks/read",
        "Microsoft.Compute/snapshots/delete",
        "Microsoft.Compute/snapshots/write",
        "Microsoft.Compute/snapshots/beginGetAccess/action",
        "Microsoft.Compute/snapshots/read",
        "Microsoft.Compute/snapshots/endGetAccess/action"
    ]
    not_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${var.subscription_id}"
  ]
}

# 3️⃣ Assign Role to the Service Principal
resource "azurerm_role_assignment" "migrate_role_assignment" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = azurerm_role_definition.migrate_custom_role.name
  principal_id         = azuread_service_principal.migrate_sp.id
}

# Variables
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "your-subscription-id"
}
