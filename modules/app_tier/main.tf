# ---------------------------------------------------------------------------------------------------------------------
# Create subnet, security list, and load balancer for app tier
# ---------------------------------------------------------------------------------------------------------------------
module "network" {
  source              = "./network"
  compartment_ocid    = var.compartment_ocid
  vcn_id              = var.vcn_id
  route_table_id      = var.route_table_id
  dhcp_options_id     = var.dhcp_options_id
  app_tier_cidr_block = var.app_tier_cidr_block
  app_lb_port         = var.app_lb_port
  vcn_cidr_block      = var.vcn_cidr_block
  tomcat_config       = var.tomcat_config
}

# ---------------------------------------------------------------------------------------------------------------------
# Create autoscaling pool and configuration for application tier
# ---------------------------------------------------------------------------------------------------------------------
module "compute" {
  source                        = "./compute"
  region                        = var.region
  ssh_public_key                = var.ssh_public_key
  tenancy_ocid                  = var.tenancy_ocid
  compartment_ocid              = var.compartment_ocid
  vcn_cidr_block                = var.vcn_cidr_block
  oci_caas_bootstrap_bucket     = var.oci_caas_bootstrap_bucket
  oci_caas_app_bootstrap_bundle = var.oci_caas_app_bootstrap_bundle
  chef_version                  = var.chef_version
  tomcat_config                 = var.tomcat_config
  app_subnet_id                 = module.network.app_subnet_id
  app_backendset_name           = module.network.app_backendset_name
  app_load_balancer_id          = module.network.app_load_balancer_id
}