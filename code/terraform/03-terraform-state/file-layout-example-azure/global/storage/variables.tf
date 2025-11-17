variable "resource_group_name" {
  description = "The name of the Azure Resource Group. Must be unique within the subscription."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be deployed."
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  description = "The name of the Azure Storage Account. Must be globally unique and lowercase."
  type        = string
}

variable "container_name" {
  description = "The name of the blob container for storing Terraform state files."
  type        = string
  default     = "tfstate"
}

variable "cosmos_db_account_name" {
  description = "The name of the Azure Cosmos DB account for state locking. Must be globally unique and lowercase."
  type        = string
}

variable "cosmos_db_database_name" {
  description = "The name of the Cosmos DB database for Terraform locks."
  type        = string
  default     = "terraform-locks"
}

variable "cosmos_db_container_name" {
  description = "The name of the Cosmos DB container for Terraform locks."
  type        = string
  default     = "locks"
}
