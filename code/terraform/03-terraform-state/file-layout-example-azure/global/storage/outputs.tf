output "storage_account_name" {
  value       = azurerm_storage_account.terraform_state.name
  description = "The name of the Storage Account"
}

output "storage_container_name" {
  value       = azurerm_storage_container.terraform_state.name
  description = "The name of the storage container for Terraform state"
}

output "cosmos_db_account_name" {
  value       = azurerm_cosmosdb_account.terraform_locks.name
  description = "The name of the Cosmos DB account for state locking"
}

output "cosmos_db_endpoint" {
  value       = azurerm_cosmosdb_account.terraform_locks.endpoint
  description = "The endpoint URL of the Cosmos DB account"
}
