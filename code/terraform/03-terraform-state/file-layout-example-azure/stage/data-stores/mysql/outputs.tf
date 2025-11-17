output "mysql_server_name" {
  value       = azurerm_mysql_server.db_server.name
  description = "The name of the MySQL server"
}

output "mysql_server_fqdn" {
  value       = azurerm_mysql_server.db_server.fqdn
  description = "The fully qualified domain name of the MySQL server"
}

output "mysql_database_name" {
  value       = azurerm_mysql_database.app_db.name
  description = "The name of the database"
}

output "mysql_server_id" {
  value       = azurerm_mysql_server.db_server.id
  description = "The resource ID of the MySQL server"
}

output "mysql_server_port" {
  value       = 3306
  description = "The default port for MySQL connections"
}
