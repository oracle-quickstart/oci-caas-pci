# ---------------------------------------------------------------------------------------------------------------------
# Random IDs to prevent naming collision with tenancy level resources
# ---------------------------------------------------------------------------------------------------------------------
resource "random_id" "policy_name" {
  byte_length = 8
}

resource "random_id" "dg_name" {
  byte_length = 8
}

# ---------------------------------------------------------------------------------------------------------------------
# Create dynamic group and IAM policy for access to CAAS resources
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_identity_dynamic_group" "caas_access_dynamic_group" {
  compartment_id = var.tenancy_ocid
  description = "OCI CaaS Object Store Access"
  matching_rule = "any {instance.compartment.id = '${var.compartment_ocid}'}"
  name = "${var.oci_dg_prefix}-${random_id.dg_name.id}"
  freeform_tags = {
    "Description" = "Dynamic group for access to CaaS bootstrap bucket"
    "Function"    = "Provides access to the CaaS bootstrap bucket"
  }
}

resource "oci_identity_policy" "caas_access_policy" {
  compartment_id = var.tenancy_ocid
  description = "OCI CaaS Object Store Access"
  name = "${var.oci_bucket_policy_prefix}-${random_id.policy_name.id}"
  freeform_tags = {
    "Description" = "Policy for access to CaaS bootstrap bucket"
    "Function"    = "Provides access to the CaaS bootstrap bucket"
  }
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.caas_access_dynamic_group.name} to read objects in compartment id ${var.compartment_ocid} where target.bucket.name='${var.oci_caas_bootstrap_bucket}'",
    "Allow dynamic-group ${oci_identity_dynamic_group.caas_access_dynamic_group.name} to read buckets in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.caas_access_dynamic_group.name} to inspect vaults in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.caas_access_dynamic_group.name} to inspect secrets in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.caas_access_dynamic_group.name} to read secrets in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.caas_access_dynamic_group.name} to read secret-bundles in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.caas_access_dynamic_group.name} to read autonomous-databases in compartment id ${var.compartment_ocid}"
  ]
}

resource "oci_identity_policy" "database_credential_access" {
  compartment_id = var.tenancy_ocid
  description = "Database credential access"
  name = "database_credentials-${random_id.policy_name.id}"
  freeform_tags = {
    "Description" = "Policy for access to database credentials"
    "Function"    = "Provides access to the application database credentials"
  }
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.caas_access_dynamic_group.name} to inspect vaults in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.caas_access_dynamic_group.name} to inspect secrets in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.caas_access_dynamic_group.name} to read secrets in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.caas_access_dynamic_group.name} to read secret-bundles in compartment id ${var.compartment_ocid}",
    "Allow dynamic-group ${oci_identity_dynamic_group.caas_access_dynamic_group.name} to read autonomous-databases in compartment id ${var.compartment_ocid}"
  ]
}

resource "oci_identity_policy" "wazuh_log_backups" {
  compartment_id = var.tenancy_ocid
  description = "Wazuh log backups"
  name = "wazuh_log_backups-${random_id.policy_name.id}"
  freeform_tags = {
    "Description" = "Policy for access to Wazuh backup bucket"
    "Function"    = "Provides access for Wazuh host to back up to backup bucket"
  }
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.caas_access_dynamic_group.name} to manage objects in compartment id ${var.compartment_ocid} where target.bucket.name='${var.wazuh_backup_bucket_name}'",
    "Allow service objectstorage-${var.region} to manage object-family in compartment id ${var.compartment_ocid}"
  ]
}