variable "compartment_ocid" {}
variable "vcn_id" {}
variable "route_table_id" {}
variable "dhcp_options_id" {}
variable "region" {}
variable "ssh_public_key" {}
variable "tenancy_ocid" {}

variable "dmz_cidr_block" {
  type        = string
  description = "[DMZ Subnet] CIDR Block"
}

variable "web_tier_cidr_block" {
  type        = string
  description = "[Web tier Subnet] CIDR Block"
}

variable "vcn_cidr_block" {
  type = string
  description = "[VCN] CIDR Block"
}