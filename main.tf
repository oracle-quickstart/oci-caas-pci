# ---------------------------------------------------------------------------------------------------------------------
# Create VCN and shared network infrastructure (subnets, gateways, etc...)
# ---------------------------------------------------------------------------------------------------------------------
module "vcn" {
  source           = "./modules/common/vcn"
  compartment_ocid = var.compartment_ocid
  vcn_cidr_block   = var.primary_vcn_cidr_block
}

# ---------------------------------------------------------------------------------------------------------------------
# Create WAF and DNS CNAME for user access
# ---------------------------------------------------------------------------------------------------------------------
module "waf" {
  source                      = "./modules/common/waf"
  compartment_ocid            = var.compartment_ocid
  frontend_dns_name           = var.frontend_dns_name
  vcn_cidr_block              = var.primary_vcn_cidr_block
  frontend_ssl_certificate_id = var.frontend_ssl_certificate_id
  dmz_load_balancer_ip        = module.app_tier.frontend_load_balancer_ips[0].ip_address
  domain_name                 = module.dns.dns_zone
}

# ---------------------------------------------------------------------------------------------------------------------
# Create DNS child zone and related records
# ---------------------------------------------------------------------------------------------------------------------
module "dns" {
  source           = "./modules/common/dns"
  compartment_ocid = var.compartment_ocid
  dns_domain_name  = var.dns_domain_name
  unique_prefix    = var.unique_prefix
}

module "objectstore" {
  source           = "./modules/common/objectstore"
  compartment_ocid = var.compartment_ocid
  os_namespace     = var.os_namespace
  unique_prefix    = var.unique_prefix
  bucket_suffix    = "wazuh-backup-bucket"
}

module "audit_retention" {
  source       = "./modules/common/audit"
  tenancy_ocid = var.tenancy_ocid
}

# ---------------------------------------------------------------------------------------------------------------------
# Create IAM resources (policies, groups)
# ---------------------------------------------------------------------------------------------------------------------
module "iam" {
  source                    = "./modules/common/iam"
  tenancy_ocid              = var.tenancy_ocid
  compartment_ocid          = var.compartment_ocid
  oci_caas_bootstrap_bucket = var.oci_caas_bootstrap_bucket
  region                    = var.region
  wazuh_backup_bucket_name  = module.objectstore.wazuh_backup_bucket_name
}

# ---------------------------------------------------------------------------------------------------------------------
# Create Bastion server and related resources (instance, subnet, security list)
# ---------------------------------------------------------------------------------------------------------------------
module "bastion" {
  source                            = "./modules/bastion"
  tenancy_ocid                      = var.tenancy_ocid
  ssh_public_key                    = var.ssh_public_key
  region                            = var.region
  compartment_ocid                  = var.compartment_ocid
  bastion_cidr_block                = var.bastion_subnet_cidr_block
  wazuh_tier_cidr_block             = var.wazuh_tier_subnet_cidr_block
  oci_caas_bootstrap_bucket         = var.oci_caas_bootstrap_bucket
  oci_caas_bastion_bootstrap_bundle = var.oci_caas_bastion_bootstrap_bundle
  vcn_cidr_block                    = var.primary_vcn_cidr_block
  chef_version                      = var.chef_version
  wazuh_server                      = module.wazuh.wazuh_server_ip
  external_fqdn                     = module.waf.fqdn
  vcn_id                            = module.vcn.vcn_id
  route_table_id                    = module.vcn.default_route_table_id
  dhcp_options_id                   = module.vcn.dhcp_options_id
}

# ---------------------------------------------------------------------------------------------------------------------
# Create application autoscaling servers and related resources (instance config, pools, subnet, security list)
# ---------------------------------------------------------------------------------------------------------------------
module "app_tier" {
  source                        = "./modules/app_tier"
  tenancy_ocid                  = var.tenancy_ocid
  ssh_public_key                = var.ssh_public_key
  region                        = var.region
  compartment_ocid              = var.compartment_ocid
  app_tier_cidr_block           = var.app_tier_subnet_cidr_block
  vcn_cidr_block                = var.primary_vcn_cidr_block
  oci_caas_bootstrap_bucket     = var.oci_caas_bootstrap_bucket
  oci_caas_app_bootstrap_bundle = var.oci_caas_app_bootstrap_bundle
  chef_version                  = var.chef_version
  tomcat_config                 = var.tomcat_config
  wazuh_tier_cidr_block         = var.wazuh_tier_subnet_cidr_block
  app_war_file                  = var.app_war_file
  dmz_cidr_block                = var.dmz_subnet_cidr_block
  unique_prefix                 = var.unique_prefix
  app_autoscaling_min           = var.app_autoscaling_min
  app_autoscaling_initial       = var.app_autoscaling_initial
  app_autoscaling_max           = var.app_autoscaling_max
  database_id                   = module.database.database_id
  database_name                 = module.database.database_name
  wazuh_server                  = module.wazuh.wazuh_server_ip
  vcn_id                        = module.vcn.vcn_id
  route_table_id                = module.vcn.nat_route_table_id
  dhcp_options_id               = module.vcn.dhcp_options_id
}

# ---------------------------------------------------------------------------------------------------------------------
# Create database and subnet with security lists
# ---------------------------------------------------------------------------------------------------------------------
module "database" {
  source                 = "./modules/database"
  tenancy_ocid           = var.tenancy_ocid
  ssh_public_key         = var.ssh_public_key
  region                 = var.region
  compartment_ocid       = var.compartment_ocid
  database_cidr_block    = var.database_subnet_cidr_block
  database_password      = var.database_password
  vcn_cidr_block         = var.primary_vcn_cidr_block
  database_listener_port = var.database_listener_port
  vcn_id                 = module.vcn.vcn_id
  route_table_id         = module.vcn.default_route_table_id
  dhcp_options_id        = module.vcn.dhcp_options_id
}

# ---------------------------------------------------------------------------------------------------------------------
# Create Wazuh server and related resources (subnet, security list)
# ---------------------------------------------------------------------------------------------------------------------
module "wazuh" {
  source                     = "./modules/wazuh"
  tenancy_ocid               = var.tenancy_ocid
  ssh_public_key             = var.ssh_public_key
  region                     = var.region
  compartment_ocid           = var.compartment_ocid
  wazuh_tier_cidr_block      = var.wazuh_tier_subnet_cidr_block
  dmz_cidr_block             = var.dmz_subnet_cidr_block
  vcn_cidr_block             = var.primary_vcn_cidr_block
  wazuh_server_vcn_tcp_ports = var.wazuh_server_vcn_tcp_ports
  wazuh_server_vcn_udp_ports = var.wazuh_server_vcn_udp_ports
  wazuh_backup_bucket_name   = module.objectstore.wazuh_backup_bucket_name
  oci_caas_bootstrap_bucket  = var.oci_caas_bootstrap_bucket
  vcn_id                     = module.vcn.vcn_id
  route_table_id             = module.vcn.nat_route_table_id
  dhcp_options_id            = module.vcn.dhcp_options_id
}