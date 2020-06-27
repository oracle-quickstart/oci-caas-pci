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

module "vcn" {
  source           = "./modules/common/vcn"
  compartment_ocid = var.compartment_ocid
}

module "caas_base" {
  source           = "./modules/common/caas_base"
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  caas_bucket_name = var.caas_bucket_name
}

module "bastion" {
  source           = "./modules/bastion"
  tenancy_ocid     = var.tenancy_ocid
  ssh_public_key   = var.ssh_public_key
  vcn_id           = module.vcn.vcn_id
  region           = var.region
  compartment_ocid = var.compartment_ocid
  route_table_id   = module.vcn.default_route_table_id
  dhcp_options_id  = module.vcn.dhcp_options_id
}

module "web_tier" {
  source           = "./modules/web_tier"
  tenancy_ocid     = var.tenancy_ocid
  ssh_public_key   = var.ssh_public_key
  vcn_id           = module.vcn.vcn_id
  region           = var.region
  compartment_ocid = var.compartment_ocid
  route_table_id   = module.vcn.nat_route_table_id
  dhcp_options_id  = module.vcn.dhcp_options_id
}

output "vcn_id" {
  value = module.vcn.vcn_id
  description = "VCN OCID"
}

output "dhcp_options_id" {
  value = module.vcn.dhcp_options_id
  description = "DHCP Options OCID"
}

output "nat_gateway_id" {
  value = module.vcn.nat_gateway_id
  description = "NAT gateway"
}

output "nat_route_table_id" {
  value = module.vcn.nat_route_table_id
  description = "NAT route table"
}