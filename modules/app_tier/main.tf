# ---------------------------------------------------------------------------------------------------------------------
# Create subnet, security list, and load balancer for app tier
# ---------------------------------------------------------------------------------------------------------------------
module "network" {
  source                 = "./network"
  compartment_ocid       = var.compartment_ocid
  vcn_id                 = var.vcn_id
  route_table_id         = var.route_table_id
  dhcp_options_id        = var.dhcp_options_id
  app_tier_cidr_block    = var.app_tier_cidr_block
  app_lb_port            = var.app_lb_port
  vcn_cidr_block         = var.vcn_cidr_block
  tomcat_config          = var.tomcat_config
}

# ---------------------------------------------------------------------------------------------------------------------
# Create autoscaling pool and configuration for application tier
# ---------------------------------------------------------------------------------------------------------------------
module "compute" {
  source                        = "./compute"
  region                        = var.region
  database_id                   = var.database_id
  database_name                 = var.database_name
  ssh_public_key                = var.ssh_public_key
  tenancy_ocid                  = var.tenancy_ocid
  compartment_ocid              = var.compartment_ocid
  vcn_cidr_block                = var.vcn_cidr_block
  oci_caas_bootstrap_bucket     = var.oci_caas_bootstrap_bucket
  oci_caas_app_bootstrap_bundle = var.oci_caas_app_bootstrap_bundle
  cinc_version                  = var.cinc_version
  tomcat_config                 = var.tomcat_config
  app_war_file                  = var.app_war_file
  wazuh_server                  = var.wazuh_server
  unique_prefix                 = var.unique_prefix
  app_autoscaling_min           = var.app_autoscaling_min
  app_autoscaling_initial       = var.app_autoscaling_initial
  app_autoscaling_max           = var.app_autoscaling_max
  app_subnet_id                 = module.network.app_subnet_id
  dmz_backendset_name           = module.load_balancer.dmz_backendset_name
  dmz_load_balancer_id          = module.load_balancer.dmz_load_balancer_id
}

module "load_balancer" {
  source           = "./load_balancer"
  vcn_id           = var.vcn_id
  compartment_ocid = var.compartment_ocid
  dmz_cidr_block   = var.dmz_cidr_block
  server_port      = var.tomcat_config["http_port"]
  app_subnet_id    = module.network.app_subnet_id
  app_lb_port      = var.app_lb_port
}

output "frontend_load_balancer_ips" {
  value = module.load_balancer.frontend_load_balancer_ips
}