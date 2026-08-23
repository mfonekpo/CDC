output "org_name" {
  description = "snowflake org_name"
  value       = var.organization_name
}

output "account_name" {
  description = "snowflake account_name"
  value       = var.account_name
}

output "user" {
  description = "snowflake user"
  value       = var.user
}

output "role" {
  description = "snowflake role"
  value       = var.role
}

output "warehouse_name" {
  description = "cdc data warehouse name"
  value       = snowflake_warehouse.cdc_warehouse.name
}

output "warehouse_size" {
  description = "cdc data warehouse size"
  value       = snowflake_warehouse.cdc_warehouse.warehouse_size
}