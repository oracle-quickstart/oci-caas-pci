resource "oci_core_instance" "bastion" {
  compartment_id      = var.compartment_ocid
  availability_domain = lookup(data.oci_identity_availability_domains.ad.availability_domains[0],"name")

  create_vnic_details {
    assign_public_ip = true
    display_name     = "bastion-vnic"
    hostname_label   = "bastion"
    subnet_id        = var.subnet_id
  }

  display_name = "bastion"

  metadata = {
    ssh_authorized_keys = file (var.ssh_public_key)
    user_data           = base64encode(file("${path.module}/userdata/bastion-bootstrap"))
  }

  shape = var.bastion_instance_shape

  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid[var.region]
  }

  timeouts {
    create = "10m"
  }

  count = var.bastion_enabled == true ? 1 : 0
}
