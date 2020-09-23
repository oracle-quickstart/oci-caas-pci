# ---------------------------------------------------------------------------------------------------------------------
# Create single instance - can be toggled off by setting bastion_enabled to false.
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_instance" "bastion" {
  compartment_id      = var.compartment_ocid
  availability_domain = lookup(data.oci_identity_availability_domains.ad.availability_domains[0],"name")
  shape               = var.bastion_instance_shape
  display_name        = "bastion"

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

resource "random_id" "otp_one" {
  byte_length = 8
}

resource "random_id" "otp_two" {
  byte_length = 8
}

resource "random_id" "otp_three" {
  byte_length = 8
}

# Bootstrap data
data "template_file" bootstrap {
  template = file("${path.module}/userdata/bootstrap")

  vars = {
    bootstrap_bucket = var.oci_caas_bootstrap_bucket
    bootstrap_bundle = var.oci_caas_bastion_bootstrap_bundle
    chef_version     = var.chef_version
    vcn_cidr_block   = var.vcn_cidr_block
    wazuh_server     = var.wazuh_server
    otp_one          = substr(random_id.otp_one.dec, 0, 8)
    otp_two          = substr(random_id.otp_two.dec, 0, 8)
    otp_three        = substr(random_id.otp_three.dec, 0, 8)
  }
}

# Adding the 0 is how we make the OTP 8 characters long
output "otp_one" {
  value = substr(random_id.otp_one.dec, 0, 8)
}

output "otp_two" {
  value = substr(random_id.otp_two.dec, 0, 8)
}

output "otp_three" {
  value = substr(random_id.otp_three.dec, 0, 8)
}

data "oci_core_instance" "bastion_host" {
  instance_id = oci_core_instance.bastion.id
}

output "bastion_ip" {
  value = data.oci_core_instance.bastion_host.public_ip
}