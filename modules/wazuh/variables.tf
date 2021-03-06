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

variable "oci_caas_bootstrap_bucket" {
  type        = string
  description = "Name of the bucket created during bootstrapping."
}

variable "wazuh_backup_bucket_name" {
  type = string
  description = "Bucket name for Wazuh backups"
}

variable "wazuh_tier_cidr_block" {
  type        = string
  description = "[Wazuh tier Subnet] CIDR Block"
}

variable "vcn_cidr_block" {
  type = string
  description = "[VCN] CIDR Block"
}

variable "wazuh_server_vcn_tcp_ports" {
  type    = list
  description = "[Wazuh Security List] Inbound TCP ports (internal to VCN)"
  default = [22, 443, 1515]
}

variable "wazuh_server_vcn_udp_ports" {
  type    = list
  description = "[Wazuh Security List] Inbound UDP ports (internal to VCN)"
  default = [1514]
}

variable "oci_caas_wazuh_bootstrap_bundle" {
  type        = string
  description = "File name for the bootstrap bundle."
}

variable "cinc_version" {
  type        = string
  description = "Version of the Cinc Infra client from bootstrapping"
}