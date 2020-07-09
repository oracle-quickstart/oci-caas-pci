# ---------------------------------------------------------------------------------------------------------------------
# Create database
# ---------------------------------------------------------------------------------------------------------------------

resource "oci_database_autonomous_database" "database" {
  admin_password           = var.database_password
  compartment_id           = var.compartment_ocid
  cpu_core_count           = var.database_cpu_core_count
  data_storage_size_in_tbs = var.database_data_storage_size_in_tbs
  db_name                  = var.database_db_name
  db_version               = var.database_db_version
  display_name             = var.database_display_name
#   freeform_tags            = var.database_freeform_tags
  license_model            = var.database_license_model
  nsg_ids                  = [var.database_security_group_id]   
#   private_endpoint_label   = var.private_endpoint_label
  subnet_id                = var.database_subnet_id  
}

resource "random_string" "database_wallet_password" {
  length  = 16
  special = true
}

resource "local_file" "autonomous_data_warehouse_wallet_file" {
  content_base64 = data.oci_database_autonomous_database_wallet.database_wallet.content
  filename       = "${path.module}/database_wallet.zip"
}

data "oci_database_autonomous_database_wallet" "database_wallet" {
  autonomous_database_id = oci_database_autonomous_database.database.id
  password               = random_string.database_wallet_password.result
  base64_encode_content  = "true"
}

output "database_wallet_password" {
  value = [random_string.database_wallet_password.result]
}