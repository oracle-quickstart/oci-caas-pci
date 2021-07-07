variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "subnet_id" {}
variable "ssh_public_key" {}
variable "region" {}

variable "wazuh_backup_bucket_name" {
  type = string
  description = "Bucket name for Wazuh backups"
}

variable "oci_caas_bootstrap_bucket" {
  type        = string
  description = "Name of the bucket created during bootstrapping."
}

variable "wazuh_server_port" {
  type = number
  description = "[Wazuh Instance] HTTP Port"
  default = 80
}

variable "wazuh_storage_gb" {
  type = number
  description = "[Wazuh Instance] Size in GB"
  default = 500
}

variable "num_paravirtualized_volumes_per_instance" {
  default = "1"
}

variable "wazuh_instance_shape" {
  type = string
  description = "[Wazuh Instance] Shape"
  default = "VM.Standard2.2"
}

variable "num_instances" {
  default = "1"
}

variable "vcn_cidr_block" {
  type = string
  description = "[VCN] CIDR Block"
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

variable "oci_caas_wazuh_bootstrap_bundle" {
  type        = string
  description = "File name for the bootstrap bundle."
}

variable "cinc_version" {
  type        = string
  description = "Version of the Cinc Infra client from bootstrapping"
}