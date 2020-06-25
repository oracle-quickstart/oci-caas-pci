variable "compartment_ocid" {}
variable "tenancy_ocid" {}

variable "oci_dg_prefix" {
  type = string
  description = "[OCI CaaS] Dynamic group name, used for bucket access"
  default = "oci_caas_bucket_access"
}

variable "oci_bucket_policy_prefix" {
  type = string
  description = "[OCI CaaS] Policy name, used for bucket access"
  default = "oci_caas_bucket_access"
}

resource "random_id" "policy_name" {
  byte_length = 8
}

resource "random_id" "dg_name" {
  byte_length = 8
}

resource "oci_identity_dynamic_group" "test_dynamic_group" {
    compartment_id = var.tenancy_ocid
    description = "OCI CaaS Object Store Access"
    matching_rule = "any {instance.compartment.id = '${var.compartment_ocid}'}"
    name = "${var.oci_dg_prefix}-${random_id.dg_name.id}"
}

resource "oci_identity_policy" "test_policy" {
    compartment_id = var.tenancy_ocid
    description = "OCI CaaS Object Store Access"
    name = "${var.oci_bucket_policy_prefix}-${random_id.policy_name.id}"
    statements = [
      "Allow dynamic-group ${oci_identity_dynamic_group.test_dynamic_group.name} to read objects in compartment id ${var.compartment_ocid} where target.bucket.name='chef-cookbooks'",
      "Allow dynamic-group ${oci_identity_dynamic_group.test_dynamic_group.name} to read buckets in compartment id ${var.compartment_ocid}"
    ]
}
