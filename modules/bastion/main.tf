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
  chef_version                      = var.chef_version
  subnet_id                         = module.network.subnet_id
}

output "otp_one" {
  value = module.compute.otp_one
}

output "otp_two" {
  value = module.compute.otp_two
}

output "otp_three" {
  value = module.compute.otp_three
}

output "bastion_ip" {
  value = module.compute.bastion_ip
}