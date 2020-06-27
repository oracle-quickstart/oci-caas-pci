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

variable "caas_bucket_name" {
  type = string
  description = "[OCI CaaS] Bucket name"
  default = "chef-cookbooks"
}