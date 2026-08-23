terraform {
  required_providers {
    snowflake = {
      source = "snowflakedb/snowflake"
    }
  }
}



locals {
  private_key_path = pathexpand("~/tf_key.p8")
}

provider "snowflake" {
  organization_name = var.organization_name
  account_name      = var.account_name
  user              = var.user
  role              = var.role
  authenticator     = "SNOWFLAKE_jwt"
  private_key       = file((local.private_key_path))
}