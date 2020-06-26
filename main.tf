variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_public_key" {}

module "vcn" {
  source           = "./modules/common/vcn"
  compartment_ocid = var.compartment_ocid
}

# module "compute" {
#   source               = "./modules/services/compute"
#   region               = var.region
#   ssh_public_key       = var.ssh_public_key
#   tenancy_ocid         = var.tenancy_ocid
#   compartment_ocid     = var.compartment_ocid
#   bastion_subnet_id    = module.vcn.bastion_subnet_id
#   web_subnet_id        = module.vcn.web_subnet_id
#   web_server_port      = var.web_server_port
#   dmz_backendset_name  = module.load_balancer.dmz_backendset_name
#   dmz_load_balancer_id = module.load_balancer.dmz_load_balancer_id
# }

# commented out for testing
# module "caas_base" {
#   source           = "./common/caas_base"
#   tenancy_ocid     = var.tenancy_ocid
#   compartment_ocid = var.compartment_ocid
# }

# module "web_tier" {
#   source           = "./modules/web_tier"
#   vcn_id           = module.vcn.vcn_id
#   compartment_ocid = var.compartment_ocid
#   route_table_id = module.vcn.nat_gateway_id
#   dhcp_options_id = module.vcn.dhcp_options_id
# }

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