# ---------------------------------------------------------------------------------------------------------------------
# Create database
# ---------------------------------------------------------------------------------------------------------------------
resource "random_id" "database_name" {
  byte_length = 2
}

resource "oci_database_autonomous_database" "database" {
  admin_password           = var.database_password
  compartment_id           = var.compartment_ocid
  cpu_core_count           = var.database_cpu_core_count
  data_storage_size_in_tbs = var.database_data_storage_size_in_tbs
  db_name                  = "${var.database_db_name}${random_id.database_name.hex}"
  db_version               = var.database_db_version
  display_name             = var.database_display_name
  license_model            = var.database_license_model
  nsg_ids                  = [var.database_security_group_id]
  subnet_id                = var.database_subnet_id  
}