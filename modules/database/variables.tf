variable "compartment_ocid" {}
variable "vcn_id" {}
variable "route_table_id" {}
variable "dhcp_options_id" {}
variable "region" {}
variable "ssh_public_key" {}
variable "tenancy_ocid" {}
variable "database_password" {}
variable "vcn_cidr_block" {}

variable "database_cidr_block" {
  type        = string
  description = "[Database Subnet] CIDR Block"
}

variable "database_listener_port" {
  description = "[Database] Listener port"
  type        = number
  default     = 1522
}