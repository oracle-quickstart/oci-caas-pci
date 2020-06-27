variable "compartment_ocid" {}
variable "vcn_id" {}
variable "route_table_id" {}
variable "dhcp_options_id" {}
variable "region" {}
variable "ssh_public_key" {}
variable "tenancy_ocid" {}

module "network" {
  source           = "./network"
  compartment_ocid = var.compartment_ocid
  vcn_id           = var.vcn_id
  route_table_id   = var.route_table_id
  dhcp_options_id  = var.dhcp_options_id
}

module "compute" {
  source               = "./compute"
  region               = var.region
  ssh_public_key       = var.ssh_public_key
  tenancy_ocid         = var.tenancy_ocid
  compartment_ocid     = var.compartment_ocid
  web_subnet_id        = module.network.web_subnet_id
  dmz_backendset_name  = module.load_balancer.dmz_backendset_name
  dmz_load_balancer_id = module.load_balancer.dmz_load_balancer_id
}

module "load_balancer" {
  source           = "./load_balancer"
  vcn_id           = var.vcn_id
  compartment_ocid = var.compartment_ocid
  web_subnet_id    = module.network.web_subnet_id
  web_server_port  = module.compute.web_server_port
}