# ---------------------------------------------------------------------------------------------------------------------
# Create subnet, security list, and load balancer for database
# ---------------------------------------------------------------------------------------------------------------------
module "network" {
  source              = "./network"
  compartment_ocid    = var.compartment_ocid
  vcn_id              = var.vcn_id
  route_table_id      = var.route_table_id
  dhcp_options_id     = var.dhcp_options_id
  database_cidr_block = var.database_cidr_block
  vcn_cidr_block      = var.vcn_cidr_block
}

# ---------------------------------------------------------------------------------------------------------------------
# Create atp database and configuration
# ---------------------------------------------------------------------------------------------------------------------
module "atp" {
  source               = "./atp"
  region               = var.region
  ssh_public_key       = var.ssh_public_key
  tenancy_ocid         = var.tenancy_ocid
  compartment_ocid     = var.compartment_ocid
  database_subnet_id   = module.network.database_subnet_id
  database_password    = var.database_password
  database_security_group_id = module.network.database_security_group_id
}