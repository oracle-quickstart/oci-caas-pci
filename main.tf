# ---------------------------------------------------------------------------------------------------------------------
# Create VCN and shared network infrastructure (subnets, gateways, etc...)
# ---------------------------------------------------------------------------------------------------------------------
module "vcn" {
  source           = "./modules/common/vcn"
  compartment_ocid = var.compartment_ocid
  vcn_cidr_block   = var.primary_vcn_cidr_block
}

# ---------------------------------------------------------------------------------------------------------------------
# Create DNS child zone and related records
# ---------------------------------------------------------------------------------------------------------------------
module "dns" {
  source           = "./modules/common/dns"
  compartment_ocid = var.compartment_ocid
  dns_domain_name  = var.dns_domain_name
  frontend_ips     = module.web_tier.frontend_load_balancer_ips
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
  source             = "./modules/bastion"
  tenancy_ocid       = var.tenancy_ocid
  ssh_public_key     = var.ssh_public_key
  region             = var.region
  compartment_ocid   = var.compartment_ocid
  bastion_cidr_block = var.bastion_subnet_cidr_block
  vcn_id             = module.vcn.vcn_id
  route_table_id     = module.vcn.default_route_table_id
  dhcp_options_id    = module.vcn.dhcp_options_id
}

# ---------------------------------------------------------------------------------------------------------------------
# Create web autoscaling servers and related resources (instance config, pools, subnet, security list)
# ---------------------------------------------------------------------------------------------------------------------
module "web_tier" {
  source              = "./modules/web_tier"
  tenancy_ocid        = var.tenancy_ocid
  ssh_public_key      = var.ssh_public_key
  region              = var.region
  compartment_ocid    = var.compartment_ocid
  web_tier_cidr_block = var.web_tier_subnet_cidr_block
  dmz_cidr_block      = var.dmz_subnet_cidr_block
  vcn_cidr_block      = var.primary_vcn_cidr_block
  vcn_id              = module.vcn.vcn_id
  route_table_id      = module.vcn.nat_route_table_id
  dhcp_options_id     = module.vcn.dhcp_options_id
}

# ---------------------------------------------------------------------------------------------------------------------
# Create application autoscaling servers and related resources (instance config, pools, subnet, security list)
# ---------------------------------------------------------------------------------------------------------------------
module "app_tier" {
  source              = "./modules/app_tier"
  tenancy_ocid        = var.tenancy_ocid
  ssh_public_key      = var.ssh_public_key
  region              = var.region
  compartment_ocid    = var.compartment_ocid
  app_tier_cidr_block = var.app_tier_subnet_cidr_block
  vcn_cidr_block      = var.primary_vcn_cidr_block
  tomcat_http_port    = var.tomcat_http_port
  vcn_id              = module.vcn.vcn_id
  route_table_id      = module.vcn.service_gateway_route_table_id
  dhcp_options_id     = module.vcn.dhcp_options_id
}


# ---------------------------------------------------------------------------------------------------------------------
# Create database and subnet with security lists
# ---------------------------------------------------------------------------------------------------------------------
module "database" {
  source              = "./modules/database"
  tenancy_ocid        = var.tenancy_ocid
  ssh_public_key      = var.ssh_public_key
  region              = var.region
  compartment_ocid    = var.compartment_ocid
  database_cidr_block = var.database_subnet_cidr_block
  database_password   = var.database_password
  vcn_cidr_block      = var.primary_vcn_cidr_block
  vcn_id              = module.vcn.vcn_id
  route_table_id      = module.vcn.default_route_table_id
  dhcp_options_id     = module.vcn.dhcp_options_id
}