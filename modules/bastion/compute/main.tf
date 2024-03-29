# ---------------------------------------------------------------------------------------------------------------------
# Create single instance - can be toggled off by setting bastion_enabled to false.
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_instance" "bastion" {
  compartment_id      = var.compartment_ocid
  availability_domain = lookup(data.oci_identity_availability_domains.ad.availability_domains[0],"name")
  shape               = var.bastion_instance_shape
  is_pv_encryption_in_transit_enabled = true
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
    source_id   = data.oci_core_images.autonomous_images.images.0.id
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

output "bastion_ip" {
  value = data.oci_core_instance.bastion_host.public_ip
}