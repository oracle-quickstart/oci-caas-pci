variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "subnet_id" {}
variable "ssh_public_key" {}
variable "region" {}

variable "oci_caas_bootstrap_bucket" {
  type        = string
  description = "Name of the bucket created during bootstrapping."
}

variable "vcn_cidr_block" {
  type = string
  description = "[VCN] CIDR Block"
}

variable "oci_caas_bastion_bootstrap_bundle" {
  type        = string
  description = "File name for the bootstrap bundle."
}

variable "chef_version" {
  type        = string
  description = "Version of the Chef Infra client from bootstrapping"
}

variable "bastion_enabled" {
  type = bool
  description = "[Bastion Instance] Enabled (true/false)?"
  default = true
}

variable "wazuh_server" {
  type = string
  description = "[Wazuh] Server frontend port"
}

variable "bastion_instance_shape" {
  type = string
  description = "[Bastion Instance] Shape"
  default = "VM.Standard2.2"
}

variable "instance_image_ocid" {
  type = map

  default = {
    # See https://docs.us-phoenix-1.oraclecloud.com/images/
    # Oracle-Autonomous-Linux-7.x
    # Oracle-Autonomous-Linux-7.8-2020.04-0
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaax6mhsb3xey2gaz3ftkjwta5qkyr5se7va22sspbxghonldndph6a"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaajb2c3ew4peg7lrlzjwpam3vksrouvuysooh663nvqm5acb6tl4ya"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaat27bladiw33zqkw2amhg35tq4gqxdwerhsoabskqgcqpq7bhh52q"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaa4r6gjlmo33yscossp7h6w6j3ry3eh2mwppsjnh26w3xakumvnrpa"
  }
}
