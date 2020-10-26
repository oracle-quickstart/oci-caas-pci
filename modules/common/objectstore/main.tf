resource "oci_objectstorage_bucket" "wazuh_backup_bucket" {
  compartment_id = var.compartment_ocid
  namespace      = var.os_namespace
  name           = "${var.unique_prefix}-${var.bucket_suffix}"
  freeform_tags = {
    "Description" = "Wazuh backup bucket"
    "Function"    = "Object store bucket for Wazuh log backups"
  }

  access_type = "NoPublicAccess"
}

resource "oci_logging_log_group" "wazuh_backup_logs" {
  compartment_id = var.compartment_ocid
  display_name   = "wazuh_backup_log_group"
  freeform_tags = {
    "Description" = "Wazuh backup bucket log group"
    "Function"    = "Allows logging for access to the Wazuh backup bucket"
  }
}

resource "oci_logging_log" "wazuh_backup_writes" {
  display_name = "wazuh_backup_writes"
  log_group_id = oci_logging_log_group.wazuh_backup_logs.id
  log_type = "SERVICE"
  freeform_tags = {
    "Description" = "Wazuh backup bucket logs - writes"
    "Function"    = "Allows logging for write access to the Wazuh backup bucket"
  }

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
  freeform_tags = {
    "Description" = "Wazuh backup bucket logs - reads"
    "Function"    = "Allows logging for read access to the Wazuh backup bucket"
  }

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