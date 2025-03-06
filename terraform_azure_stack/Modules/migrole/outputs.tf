output "subscription_id" {
  value       = data.azurerm_subscription.current
  description = "subscription id"
}

output "client_id" {
  value       = azuread_service_principal.migrate_sp.client_id
  description = "client id"
}

output "tenant_id" {
  value       = azuread_service_principal.migrate_sp.application_tenant_id
  description = "tenant id"
}

output "client_secret" {
  value       = azuread_service_principal_password.migrate_sp_password.value
  description = "client secret"
}

