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
}

resource "oci_identity_policy" "caas_access_policy" {
    compartment_id = var.tenancy_ocid
    description = "OCI CaaS Object Store Access"
    name = "${var.oci_bucket_policy_prefix}-${random_id.policy_name.id}"
    statements = [
      "Allow dynamic-group ${oci_identity_dynamic_group.caas_access_dynamic_group.name} to read objects in compartment id ${var.compartment_ocid} where target.bucket.name='${var.caas_bucket_name}'",
      "Allow dynamic-group ${oci_identity_dynamic_group.caas_access_dynamic_group.name} to read buckets in compartment id ${var.compartment_ocid}"
    ]
}