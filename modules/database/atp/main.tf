# ---------------------------------------------------------------------------------------------------------------------
# Create database
# ---------------------------------------------------------------------------------------------------------------------
resource "random_id" "database_name" {
  byte_length = 2
}

resource "oci_data_safe_data_safe_configuration" "data_safe_configuration" {
  is_enabled = true
} 

resource "oci_data_safe_data_safe_private_endpoint" "data_safe_private_endpoint" {
  compartment_id = var.compartment_ocid
  display_name   = "Data safe private endpoint - ${random_id.database_name.hex}"
  subnet_id      = var.database_subnet_id
  vcn_id         = var.vcn_id
  depends_on     = [ oci_data_safe_data_safe_configuration.data_safe_configuration ]
  freeform_tags = {
    "Description" = "Data safe endpoint"
    "Function"    = "Data safe endpoint for registering databases"
  }
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
  data_safe_status         = "REGISTERED"
  depends_on               = [ oci_data_safe_data_safe_private_endpoint.data_safe_private_endpoint ]
  freeform_tags = {
    "Description" = "Autonomous database"
    "Function"    = "Stores application catalogue and user info"
  }
}

output "database_id" {
  value = oci_database_autonomous_database.database.id
}

output "database_name" {
  value = oci_database_autonomous_database.database.db_name
}