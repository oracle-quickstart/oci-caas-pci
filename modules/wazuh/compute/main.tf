# ---------------------------------------------------------------------------------------------------------------------
# Create single instance for the Wazuh server stack
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_instance" "wazuh_server" {
  compartment_id      = var.compartment_ocid
  availability_domain = lookup(data.oci_identity_availability_domains.ad.availability_domains[0],"name")
  shape               = var.wazuh_instance_shape
  display_name        = "wazuh_server"
  subnet_id = var.subnet_id

  metadata = {
    ssh_authorized_keys = file (var.ssh_public_key)
    user_data           = base64encode(data.template_file.bootstrap.rendered)
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid[var.region]
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
}

# ---------------------------------------------------------------------------------------------------------------------
# Get a list of availability domains
# ---------------------------------------------------------------------------------------------------------------------
data "oci_identity_availability_domains" "ad" {
  compartment_id = "${var.tenancy_ocid}"
}

data "template_file" "ad_names" {
  count = "${length(data.oci_identity_availability_domains.ad.availability_domains)}"
  template = "${lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")}"
}

data "template_file" bootstrap {
  template = file("${path.module}/userdata/bootstrap")

  vars = {
    bootstrap_bucket = "chef-cookbooks"
    bootstrap_bundle = "wazuh_cookbooks.tar.gz"
    chef_version     = "16.1.16-1"
    vcn_cidr_block   = var.vcn_cidr_block
  }
}

data "oci_core_instance" "wazuh_server" {
  instance_id = oci_core_instance.wazuh_server.id
}