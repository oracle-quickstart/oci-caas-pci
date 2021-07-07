# ---------------------------------------------------------------------------------------------------------------------
# Get the image id of Oracle Autonomous Linux
# ---------------------------------------------------------------------------------------------------------------------
data "oci_core_images" "autonomous_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Autonomous Linux"
  operating_system_version = var.instance_operating_system_version
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# ---------------------------------------------------------------------------------------------------------------------
# Get a list of availability domains
# ---------------------------------------------------------------------------------------------------------------------
data "oci_identity_availability_domains" "ad" {
  compartment_id = var.tenancy_ocid
}

data "template_file" "ad_names" {
  count = length(data.oci_identity_availability_domains.ad.availability_domains)
  template = lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")
}

# ---------------------------------------------------------------------------------------------------------------------
# Bootstrap script and variables
# ---------------------------------------------------------------------------------------------------------------------
data "template_file" bootstrap {
  template = file("${path.module}/userdata/bootstrap")

  vars = {
    bootstrap_bucket = var.oci_caas_bootstrap_bucket
    bootstrap_bundle = var.oci_caas_app_bootstrap_bundle
    cinc_version     = var.cinc_version
    vcn_cidr_block   = var.vcn_cidr_block
    app_war_file     = var.app_war_file
    tomcat_version   = var.tomcat_config["version"]
    shutdown_port    = var.tomcat_config["shutdown_port"]
    http_port        = var.tomcat_config["http_port"]
    https_port       = var.tomcat_config["https_port"]
    wazuh_server     = var.wazuh_server
    compartment_id   = var.compartment_ocid
    database_id      = var.database_id
    database_name    = var.database_name
    unique_prefix    = var.unique_prefix
    wallet_password  = random_string.wallet_password.result
  }
}