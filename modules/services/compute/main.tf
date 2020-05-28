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
    assign_public_ip = true
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

resource "oci_core_volume" "web_block_volume" {
  count               = var.num_instances * var.num_iscsi_volumes_per_instance
  availability_domain = data.template_file.ad_names.*.rendered[count.index]
  compartment_id      = var.compartment_ocid
  display_name        = "WebBlock${count.index}"
  size_in_gbs         = var.web_storage_gb
}

resource "oci_core_volume_attachment" "web_block_attach" {
  count           = var.num_instances * var.num_iscsi_volumes_per_instance
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.web_instance.*.id[floor(count.index / var.num_iscsi_volumes_per_instance)]
  volume_id       = oci_core_volume.web_block_volume.*.id[count.index]
  device          = count.index == 0 ? "/dev/oracleoci/oraclevdb" : ""

  # Set this to enable CHAP authentication for an ISCSI volume attachment.
  # The oci_core_volume_attachment resource will contain the CHAP authentication
  # details via the "chap_secret" and "chap_username" attributes.
  use_chap = true
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
  count     = 2
  asset_id  = oci_core_instance.web_instance.*.boot_volume_id[count.index]
  policy_id = data.oci_core_volume_backup_policies.web_predefined_volume_backup_policies.volume_backup_policies.0.id
}

resource "null_resource" "remote-exec" {
  depends_on = [oci_core_instance.web_instance, oci_core_volume_attachment.web_block_attach]
  count      = var.num_instances * var.num_iscsi_volumes_per_instance

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "30m"
      host        = oci_core_instance.web_instance.*.public_ip[count.index % var.num_instances]
      user        = "opc"
      private_key = file(var.ssh_private_key)
    }

    inline = [
      "sudo iscsiadm -m node -o new -T ${oci_core_volume_attachment.web_block_attach.*.iqn[count.index]} -p ${oci_core_volume_attachment.web_block_attach.*.ipv4[count.index]}:${oci_core_volume_attachment.web_block_attach.*.port[count.index]}",
      "sudo iscsiadm -m node -o update -T ${oci_core_volume_attachment.web_block_attach.*.iqn[count.index]} -n node.startup -v automatic",
      "sudo iscsiadm -m node -T ${oci_core_volume_attachment.web_block_attach.*.iqn[count.index]} -p ${oci_core_volume_attachment.web_block_attach.*.ipv4[count.index]}:${oci_core_volume_attachment.web_block_attach.*.port[count.index]} -o update -n node.session.auth.authmethod -v CHAP",
      "sudo iscsiadm -m node -T ${oci_core_volume_attachment.web_block_attach.*.iqn[count.index]} -p ${oci_core_volume_attachment.web_block_attach.*.ipv4[count.index]}:${oci_core_volume_attachment.web_block_attach.*.port[count.index]} -o update -n node.session.auth.username -v ${oci_core_volume_attachment.web_block_attach.*.chap_username[count.index]}",
      "sudo iscsiadm -m node -T ${oci_core_volume_attachment.web_block_attach.*.iqn[count.index]} -p ${oci_core_volume_attachment.web_block_attach.*.ipv4[count.index]}:${oci_core_volume_attachment.web_block_attach.*.port[count.index]} -o update -n node.session.auth.password -v ${oci_core_volume_attachment.web_block_attach.*.chap_secret[count.index]}",
      "sudo iscsiadm -m node -T ${oci_core_volume_attachment.web_block_attach.*.iqn[count.index]} -p ${oci_core_volume_attachment.web_block_attach.*.ipv4[count.index]}:${oci_core_volume_attachment.web_block_attach.*.port[count.index]} -l",
    ]
  }
}

# Gets the boot volume attachments for each instance
data "oci_core_boot_volume_attachments" "web_boot_volume_attachments" {
  depends_on          = [oci_core_instance.web_instance]
  count               = var.num_instances
  availability_domain = oci_core_instance.web_instance.*.availability_domain[count.index]
  compartment_id      = var.compartment_ocid

  instance_id = oci_core_instance.web_instance.*.id[count.index]
}

data "oci_core_instance_devices" "web_instance_devices" {
  count       = var.num_instances
  instance_id = oci_core_instance.web_instance.*.id[count.index]
}

data "oci_core_volume_backup_policies" "web_predefined_volume_backup_policies" {
  filter {
    name = "display_name"

    values = [
      "bronze",
    ]
  }
}

# Output the private and public IPs of the instance
output "instance_private_ips" {
  value = [oci_core_instance.web_instance.*.private_ip]
}

output "instance_public_ips" {
  value = [oci_core_instance.web_instance.*.public_ip]
}

# Output the boot volume IDs of the instance
output "boot_volume_ids" {
  value = [oci_core_instance.web_instance.*.boot_volume_id]
}

# Output all the devices for all instances
output "instance_devices" {
  value = [data.oci_core_instance_devices.web_instance_devices.*.devices]
}

# Output the chap secret information for ISCSI volume attachments. This can be used to output
# CHAP information for ISCSI volume attachments that have "use_chap" set to true.
#output "IscsiVolumeAttachmentChapUsernames" {
#  value = ["${oci_core_volume_attachment.test_block_attach.*.chap_username}"]
#}
#
#output "IscsiVolumeAttachmentChapSecrets" {
#  value = ["${oci_core_volume_attachment.test_block_attach.*.chap_secret}"]
#}

output "silver_policy_id" {
  value = data.oci_core_volume_backup_policies.web_predefined_volume_backup_policies.volume_backup_policies.0.id
}

output "attachment_instance_id" {
  value = data.oci_core_boot_volume_attachments.web_boot_volume_attachments.*.instance_id
}

# Get a list of availability domains
data "oci_identity_availability_domains" "ad" {
  compartment_id = "${var.tenancy_ocid}"
}

data "template_file" "ad_names" {
  count = "${length(data.oci_identity_availability_domains.ad.availability_domains)}"
  template = "${lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")}"
}
