variable "resource_group_name" {
  description = "The name of the Azure Resource Group."
  type        = string
}

variable "location" {
  description = "The Azure region where the database will be deployed."
  type        = string
  default     = "East US"
}

variable "db_server_name" {
  description = "The name of the MySQL server. Must be globally unique and lowercase."
  type        = string
}

variable "db_admin_username" {
  description = "The administrator username for the MySQL server."
  type        = string
  sensitive   = true
}

variable "db_admin_password" {
  description = "The administrator password for the MySQL server. Must be at least 8 characters."
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "The name of the database to create on the MySQL server."
  type        = string
  default     = "appdb"
}

variable "db_sku_name" {
  description = "The SKU name for the MySQL server (e.g., B_Gen5_1, B_Gen5_2)."
  type        = string
  default     = "B_Gen5_1"
}

variable "db_storage_mb" {
  description = "The storage capacity for the MySQL server in MB."
  type        = number
  default     = 5120
}

variable "db_version" {
  description = "The version of MySQL to deploy (e.g., 5.7, 8.0)."
  type        = string
  default     = "5.7"
}

variable "app_subnet_id" {
  description = "The ID of the subnet where application servers will be located for private database access."
  type        = string
}
