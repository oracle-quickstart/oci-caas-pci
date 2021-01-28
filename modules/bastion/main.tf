module "network" {
  source                = "./network"
  compartment_ocid      = var.compartment_ocid
  vcn_id                = var.vcn_id
  route_table_id        = var.route_table_id
  dhcp_options_id       = var.dhcp_options_id
  bastion_cidr_block    = var.bastion_cidr_block
  wazuh_tier_cidr_block = var.wazuh_tier_cidr_block
}

module "compute" {
  source                            = "./compute"
  region                            = var.region
  ssh_public_key                    = var.ssh_public_key
  tenancy_ocid                      = var.tenancy_ocid
  compartment_ocid                  = var.compartment_ocid
  wazuh_server                      = var.wazuh_server
  oci_caas_bootstrap_bucket         = var.oci_caas_bootstrap_bucket
  oci_caas_bastion_bootstrap_bundle = var.oci_caas_bastion_bootstrap_bundle
  vcn_cidr_block                    = var.vcn_cidr_block
  cinc_version                      = var.cinc_version
  external_fqdn                     = var.external_fqdn
  subnet_id                         = module.network.subnet_id
}

output "bastion_ip" {
  value = module.compute.bastion_ip
}