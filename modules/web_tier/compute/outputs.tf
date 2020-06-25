# outputs and data used for outputs - doesn't render to calling client
data "oci_core_volume_backup_policies" "web_predefined_volume_backup_policies" {
  filter {
    name = "display_name"

    values = [
      "bronze",
    ]
  }
}


output "bronze_policy_id" {
  value = data.oci_core_volume_backup_policies.web_predefined_volume_backup_policies.volume_backup_policies.0.id
}

# Get a list of availability domains
data "oci_identity_availability_domains" "ad" {
  compartment_id = "${var.tenancy_ocid}"
}

data "template_file" "ad_names" {
  count = "${length(data.oci_identity_availability_domains.ad.availability_domains)}"
  template = "${lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")}"
}
