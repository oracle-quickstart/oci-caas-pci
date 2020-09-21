output "wazuh_backup_bucket_name" {
  value = oci_objectstorage_bucket.wazuh_backup_bucket.name
}