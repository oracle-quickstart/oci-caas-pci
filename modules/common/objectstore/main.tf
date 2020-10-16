resource "oci_objectstorage_bucket" "wazuh_backup_bucket" {
  compartment_id = var.compartment_ocid
  namespace      = var.os_namespace
  name           = "${var.unique_prefix}-${var.bucket_suffix}"

  access_type = "NoPublicAccess"
}

resource "oci_logging_log_group" "wazuh_backup_logs" {
  compartment_id = var.compartment_ocid
  display_name   = "wazuh_backup_log_group"
}

resource "oci_logging_log" "wazuh_backup_writes" {
  display_name = "wazuh_backup_writes"
  log_group_id = oci_logging_log_group.wazuh_backup_logs.id
  log_type = "SERVICE"

  configuration {
    source {
      category = "write"
      resource = oci_objectstorage_bucket.wazuh_backup_bucket.name
      service = "objectstorage"
      source_type = "OCISERVICE"
    }

    compartment_id = var.compartment_ocid
  }
  is_enabled = "true"
  retention_duration = "30"
}

resource "oci_logging_log" "wazuh_backup_reads" {
  display_name = "wazuh_backup_reads"
  log_group_id = oci_logging_log_group.wazuh_backup_logs.id
  log_type = "SERVICE"

  configuration {
    source {
      category = "read"
      resource = oci_objectstorage_bucket.wazuh_backup_bucket.name
      service = "objectstorage"
      source_type = "OCISERVICE"
    }

    compartment_id = var.compartment_ocid
  }
  is_enabled = "true"
  retention_duration = "30"
}