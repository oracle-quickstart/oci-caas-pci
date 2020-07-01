variable "compartment_ocid" {}
variable "vcn_id" {}
variable "route_table_id" {}
variable "dhcp_options_id" {}
variable "region" {}
variable "ssh_public_key" {}
variable "tenancy_ocid" {}

variable "bastion_cidr_block" {
  type        = string
  description = "[Bastion Subnet] CIDR Block"
}
