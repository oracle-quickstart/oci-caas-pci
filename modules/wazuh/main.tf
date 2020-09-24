module "network" {
  source                     = "./network"
  compartment_ocid           = var.compartment_ocid
  vcn_id                     = var.vcn_id
  route_table_id             = var.route_table_id
  dhcp_options_id            = var.dhcp_options_id
  vcn_cidr_block             = var.vcn_cidr_block
  wazuh_server_vcn_tcp_ports = var.wazuh_server_vcn_tcp_ports
  wazuh_server_vcn_udp_ports = var.wazuh_server_vcn_udp_ports
  wazuh_tier_cidr_block      = var.wazuh_tier_cidr_block
}

module "compute" {
  source                    = "./compute"
  region                    = var.region
  ssh_public_key            = var.ssh_public_key
  tenancy_ocid              = var.tenancy_ocid
  compartment_ocid          = var.compartment_ocid
  vcn_cidr_block            = var.vcn_cidr_block
  wazuh_backup_bucket_name  = var.wazuh_backup_bucket_name
  oci_caas_bootstrap_bucket = var.oci_caas_bootstrap_bucket
  subnet_id                 = module.network.wazuh_subnet_id
}

output "wazuh_server_ip" {
  value = module.compute.wazuh_server_ip
}

output "wazuh_password" {
  value = module.compute.wazuh_password
}