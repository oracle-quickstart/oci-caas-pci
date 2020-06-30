module "network" {
  source              = "./network"
  compartment_ocid    = var.compartment_ocid
  vcn_id              = var.vcn_id
  route_table_id      = var.route_table_id
  dhcp_options_id     = var.dhcp_options_id
  app_tier_cidr_block = var.app_tier_cidr_block
}

module "compute" {
  source               = "./compute"
  region               = var.region
  ssh_public_key       = var.ssh_public_key
  tenancy_ocid         = var.tenancy_ocid
  compartment_ocid     = var.compartment_ocid
  app_subnet_id        = module.network.app_subnet_id
  app_backendset_name  = module.load_balancer.app_backendset_name
  app_load_balancer_id = module.load_balancer.app_load_balancer_id
}

module "load_balancer" {
  source           = "./load_balancer"
  vcn_id           = var.vcn_id
  compartment_ocid = var.compartment_ocid
  app_subnet_id    = module.network.app_subnet_id
  app_server_port  = module.compute.app_server_port
}