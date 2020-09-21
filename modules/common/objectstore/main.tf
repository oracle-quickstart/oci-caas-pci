resource "oci_objectstorage_bucket" "wazuh_backup_bucket" {
  compartment_id = var.compartment_ocid
  namespace      = var.os_namespace
  name           = "${var.unique_prefix}-${var.bucket_suffix}"

  access_type = "NoPublicAccess"
}