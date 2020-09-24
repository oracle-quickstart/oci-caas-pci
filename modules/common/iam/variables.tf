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

variable "wazuh_backup_bucket_name" {
  type = string
  description = "Wazuh backup object store bucket name"
}

variable "oci_caas_bootstrap_bucket" {
  type        = string
  description = "Name of the bucket created during bootstrapping."
}