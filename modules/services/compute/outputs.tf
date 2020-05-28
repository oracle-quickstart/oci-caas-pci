# outputs and data used for outputs - doesn't render to calling client

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

output "bronze_policy_id" {
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
