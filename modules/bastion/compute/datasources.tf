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

# Bootstrap data
data "template_file" bootstrap {
  template = file("${path.module}/userdata/bootstrap")

  vars = {
    bootstrap_bucket = var.oci_caas_bootstrap_bucket
    bootstrap_bundle = var.oci_caas_bastion_bootstrap_bundle
    cinc_version     = var.cinc_version
    vcn_cidr_block   = var.vcn_cidr_block
    wazuh_server     = var.wazuh_server
    external_fqdn    = var.external_fqdn
  }
}

data "oci_core_instance" "bastion_host" {
  instance_id = oci_core_instance.bastion.id
}