# ---------------------------------------------------------------------------------------------------------------------
# Create single instance - can be toggled off by setting bastion_enabled to false.
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_instance" "bastion" {
  compartment_id      = var.compartment_ocid
  availability_domain = lookup(data.oci_identity_availability_domains.ad.availability_domains[0],"name")
  shape               = var.bastion_instance_shape
  display_name        = "bastion"
  freeform_tags = {
    "Description" = "Bastion host"
    "Function"    = "Allows secure connections for admin work"
  }

  create_vnic_details {
    assign_public_ip = true
    display_name     = "bastion-vnic"
    hostname_label   = "bastion"
    subnet_id        = var.subnet_id
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

  # count = var.bastion_enabled == true ? 1 : 0
}

# ---------------------------------------------------------------------------------------------------------------------
# Get a list of availability domains
# ---------------------------------------------------------------------------------------------------------------------
data "oci_identity_availability_domains" "ad" {
  compartment_id = "${var.tenancy_ocid}"
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

output "bastion_ip" {
  value = data.oci_core_instance.bastion_host.public_ip
}