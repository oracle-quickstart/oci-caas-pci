resource "oci_audit_configuration" "audit_configuration" {
  compartment_id = var.tenancy_ocid
  retention_period_days = var.audit_retention_period
}