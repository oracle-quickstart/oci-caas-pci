# ---------------------------------------------------------------------------------------------------------------------
# Create VCN and shared network infrastructure (subnets, gateways, etc...)
# ---------------------------------------------------------------------------------------------------------------------
module "vcn" {
  source           = "./modules/common/vcn"
  compartment_ocid = var.compartment_ocid
}

# ---------------------------------------------------------------------------------------------------------------------
# Create IAM resources (policies, groups)
# ---------------------------------------------------------------------------------------------------------------------
module "iam" {
  source           = "./modules/common/iam"
  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  caas_bucket_name = var.caas_bucket_name
}

# ---------------------------------------------------------------------------------------------------------------------
# Create Bastion server and related resources (instance, subnet, security list)
# ---------------------------------------------------------------------------------------------------------------------
module "bastion" {
  source           = "./modules/bastion"
  tenancy_ocid     = var.tenancy_ocid
  ssh_public_key   = var.ssh_public_key
  region           = var.region
  compartment_ocid = var.compartment_ocid
  vcn_id           = module.vcn.vcn_id
  route_table_id   = module.vcn.default_route_table_id
  dhcp_options_id  = module.vcn.dhcp_options_id
}

# ---------------------------------------------------------------------------------------------------------------------
# Create web autoscaling servers and related resources (instance config, pools, subnet, security list)
# ---------------------------------------------------------------------------------------------------------------------
module "web_tier" {
  source           = "./modules/web_tier"
  tenancy_ocid     = var.tenancy_ocid
  ssh_public_key   = var.ssh_public_key
  region           = var.region
  compartment_ocid = var.compartment_ocid
  vcn_id           = module.vcn.vcn_id
  route_table_id   = module.vcn.nat_route_table_id
  dhcp_options_id  = module.vcn.dhcp_options_id
}