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
    bootstrap_bucket   = var.oci_caas_bootstrap_bucket
    bootstrap_bundle   = var.oci_caas_wazuh_bootstrap_bundle
    cinc_version       = var.cinc_version
    backup_bucket_name = var.wazuh_backup_bucket_name
    vcn_cidr_block     = var.vcn_cidr_block
    wazuh_user         = "wazuh"
    wazuh_password     = random_password.wazuh_password.result
  }
}

data "oci_core_instance" "wazuh_server" {
  instance_id = oci_core_instance.wazuh_server.id
}