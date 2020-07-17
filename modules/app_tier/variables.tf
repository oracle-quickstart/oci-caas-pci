variable "compartment_ocid" {}
variable "vcn_id" {}
variable "route_table_id" {}
variable "dhcp_options_id" {}
variable "region" {}
variable "ssh_public_key" {}
variable "tenancy_ocid" {}

variable "app_tier_cidr_block" {
  type        = string
  description = "[App tier Subnet] CIDR Block"
}

variable "vcn_cidr_block" {
  type = string
  description = "[VCN] CIDR Block"
}

variable "app_server_port" {
  type = number
  description = "[App Instance] Port"
  default = 80
}

variable "tomcat_http_port" {
  type        = number
  description = "HTTP port for Tomcat server"
  default     = 8080
}