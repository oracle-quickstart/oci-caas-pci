variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "subnet_id" {}
variable "ssh_public_key" {}
variable "region" {}
variable "external_fqdn" {}

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

variable "cinc_version" {
  type        = string
  description = "Version of the Cinc Infra client from bootstrapping"
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

variable "instance_image_id" {
  description = "Provide a custom image id for the bastion host or leave as Autonomous."
  type        = string
  default     = "Autonomous"
}

variable "instance_operating_system_version" {
  description = "In case Autonomous Linux is used, allow specification of Autonomous version"
  type        = string
  default     = "7.9"
}
