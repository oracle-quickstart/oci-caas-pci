module "network" {
  source               = "./network"
  compartment_ocid     = var.compartment_ocid
  vcn_id               = var.vcn_id
  route_table_id       = var.route_table_id
  dhcp_options_id      = var.dhcp_options_id
  vcn_cidr_block       = var.vcn_cidr_block
  web_server_vcn_ports = var.web_server_vcn_ports
  web_tier_cidr_block  = var.web_tier_cidr_block
}

module "compute" {
  source               = "./compute"
  region               = var.region
  ssh_public_key       = var.ssh_public_key
  tenancy_ocid         = var.tenancy_ocid
  compartment_ocid     = var.compartment_ocid
  vcn_cidr_block       = var.vcn_cidr_block
  wazuh_server         = var.wazuh_server
  web_subnet_id        = module.network.web_subnet_id
  dmz_backendset_name  = module.load_balancer.dmz_backendset_name
  dmz_load_balancer_id = module.load_balancer.dmz_load_balancer_id
}

module "load_balancer" {
  source           = "./load_balancer"
  vcn_id           = var.vcn_id
  compartment_ocid = var.compartment_ocid
  dmz_cidr_block   = var.dmz_cidr_block
  web_subnet_id    = module.network.web_subnet_id
  web_server_port  = module.compute.web_server_port
}

output "frontend_load_balancer_ips" {
  value = module.load_balancer.frontend_load_balancer_ips
}