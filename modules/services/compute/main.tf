resource "oci_core_instance" "web_instance" {
  count               = var.num_instances
  availability_domain = data.template_file.ad_names.*.rendered[count.index]
  compartment_id      = var.compartment_ocid
  display_name        = "WebInstance${count.index}"
  shape               = var.web_instance_shape
  preserve_boot_volume = false

  create_vnic_details {
    subnet_id        = var.web_subnet_id
    display_name     = "Primaryvnic"
    assign_public_ip = false
    hostname_label   = "webinstance${count.index}"
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid[var.region]
  }

  metadata = {
    ssh_authorized_keys = file (var.ssh_public_key)
    user_data           = base64encode(file("${path.module}/userdata/bootstrap"))
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_volume" "web_block_volume_paravirtualized" {
  count               = var.num_instances * var.num_paravirtualized_volumes_per_instance
  availability_domain = data.template_file.ad_names.*.rendered[count.index]
  compartment_id      = var.compartment_ocid
  display_name        = "WebBlockParavirtualized${count.index}"
  size_in_gbs         = var.web_storage_gb
}

resource "oci_core_volume_attachment" "web_block_volume_attach_paravirtualized" {
  count           = var.num_instances * var.num_paravirtualized_volumes_per_instance
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.web_instance.*.id[floor(count.index / var.num_paravirtualized_volumes_per_instance)]
  volume_id       = oci_core_volume.web_block_volume_paravirtualized.*.id[count.index]
}

resource "oci_core_volume_backup_policy_assignment" "policy" {
  count     = var.num_instances
  asset_id  = oci_core_instance.web_instance.*.boot_volume_id[count.index]
  policy_id = data.oci_core_volume_backup_policies.web_predefined_volume_backup_policies.volume_backup_policies.0.id
}

# Gets the boot volume attachments for each instance
data "oci_core_boot_volume_attachments" "web_boot_volume_attachments" {
  depends_on          = [oci_core_instance.web_instance]
  count               = var.num_instances
  availability_domain = oci_core_instance.web_instance.*.availability_domain[count.index]
  compartment_id      = var.compartment_ocid

  instance_id = oci_core_instance.web_instance.*.id[count.index]
}
