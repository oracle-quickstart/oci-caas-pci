variable "compartment_ocid" {}
variable "vcn_id" {}
variable "route_table_id" {}
variable "dhcp_options_id" {}
variable "region" {}
variable "ssh_public_key" {}
variable "tenancy_ocid" {}
variable "external_fqdn" {}

variable "bastion_cidr_block" {
  type        = string
  description = "[Bastion Subnet] CIDR Block"
}

variable "wazuh_tier_cidr_block" {
  type = string
  description = "[Wazuh] CIDR block"
}

variable "wazuh_server" {
  type = string
  description = "[Wazuh] Server frontend port"
}

variable "oci_caas_bootstrap_bucket" {
  type        = string
  description = "Name of the bucket created during bootstrapping."
}

variable "oci_caas_bastion_bootstrap_bundle" {
  type        = string
  description = "File name for the bootstrap bundle."
}

variable "vcn_cidr_block" {
  type = string
  description = "[VCN] CIDR Block"
}

variable "cinc_version" {
  type        = string
  description = "Version of the Cinc Infra client from bootstrapping"
}