resource "snowflake_warehouse" "cdc_warehouse" {
  name                = "cdc-warehouse"
  comment             = "cdc pipeline warehouse"
  warehouse_type      = "STANDARD"
  warehouse_size      = "XSMALL"
  auto_suspend        = 60
  auto_resume         = true
  initially_suspended = true
  max_cluster_count   = 1
  min_cluster_count   = 1
}

resource "snowflake_database" "cdc_database" {
  name                            = "cdc_db"
  comment                         = "cdc database"
  data_retention_time_in_days     = 1
  max_data_extension_time_in_days = 10
  replace_invalid_characters      = true
}