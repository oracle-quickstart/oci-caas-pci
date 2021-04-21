# ---------------------------------------------------------------------------------------------------------------------
# Create single instance for the Wazuh server stack
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_instance" "wazuh_server" {
  compartment_id      = var.compartment_ocid
  availability_domain = lookup(data.oci_identity_availability_domains.ad.availability_domains[0],"name")
  shape               = var.wazuh_instance_shape
  display_name        = "wazuh_server"
  create_vnic_details {
    subnet_id      = var.subnet_id
  }
  freeform_tags = {
    "Description" = "Wazuh host"
    "Function"    = "Primary Wazuh instance"
  }

  metadata = {
    ssh_authorized_keys = file (var.ssh_public_key)
    user_data           = base64encode(data.template_file.bootstrap.rendered)
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid[var.region]
  }

  launch_options {
    is_pv_encryption_in_transit_enabled = true
    network_type                        = "PARAVIRTUALIZED"
  }

  timeouts {
    create = "10m"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Additional application storage
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_volume" "wazuh_block_volume_paravirtualized" {
  count               = var.num_instances * var.num_paravirtualized_volumes_per_instance
  availability_domain = data.template_file.ad_names.*.rendered[count.index]
  compartment_id      = var.compartment_ocid
  display_name        = "WazuhBlockParavirtualized${count.index}"
  size_in_gbs         = var.wazuh_storage_gb

  freeform_tags = {
    "Description" = "Wazuh block storage"
    "Function"    = "Additional storage for Wazuh service"
  }
}

resource "random_password" "wazuh_password" {
  length = 16
  special = true
  override_special = "_%@"
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