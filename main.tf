variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_public_key" {}

module "vcn" {
  source           = "./common/vcn"
  compartment_ocid = var.compartment_ocid
}

module "compute" {
  source               = "./modules/services/compute"
  region               = var.region
  ssh_public_key       = var.ssh_public_key
  tenancy_ocid         = var.tenancy_ocid
  compartment_ocid     = var.compartment_ocid
  bastion_subnet_id    = module.vcn.bastion_subnet_id
  web_subnet_id        = module.vcn.web_subnet_id
  web_server_port      = var.web_server_port
  dmz_backendset_name  = module.load_balancer.dmz_backendset_name
  dmz_load_balancer_id = module.load_balancer.dmz_load_balancer_id
}

# commented out for testing
# module "caas_base" {
#   source           = "./common/caas_base"
#   tenancy_ocid     = var.tenancy_ocid
#   compartment_ocid = var.compartment_ocid
# }

module "web_tier" {
  source           = "./web_tier"
  vcn_id           = var.vcn_id
  compartment_ocid = var.compartment_ocid
}