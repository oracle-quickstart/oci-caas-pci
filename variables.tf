variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_public_key" {}

variable "caas_bucket_name" {
  type = string
  description = "[OCI CaaS] Bucket name"
  default = "chef-cookbooks"
}