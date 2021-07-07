variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "app_subnet_id" {}
variable "ssh_public_key" {}
variable "region" {}
variable "unique_prefix" {}

variable "dmz_load_balancer_id" {}
variable "dmz_backendset_name" {}

variable "database_id" {}
variable "database_name" {}

variable "app_autoscaling_initial" {
  type = number
  description = "Application autoscaling instances - initial value"
  default = 2
}

variable "app_autoscaling_max" {
  type = number
  description = "Application autoscaling instances - max value"
  default = 3
}

variable "app_autoscaling_min" {
  type = number
  description = "Application autoscaling instances - minimum value"
  default = 2
}

variable "vcn_cidr_block" {
  type        = string
  description = "[VCN] CIDR Block"
}

variable "oci_caas_bootstrap_bucket" {
  type        = string
  description = "Name of the bucket created during bootstrapping."
}

variable "oci_caas_app_bootstrap_bundle" {
  type        = string
  description = "File name for the bootstrap bundle."
}

variable "cinc_version" {
  type        = string
  description = "Version of the Cinc Infra client from bootstrapping"
}

variable "tomcat_config" {
  type = map
  description = "Tomcat configuration variables"

  default = {
    http_port     = 8080
    https_port    = 8444
    shutdown_port = 8006
    version       = "8.5.68"
  }
}

variable "app_storage_gb" {
  type = number
  description = "[App Instance] Size in GB"
  default = 50
}

variable "num_paravirtualized_volumes_per_instance" {
  default = "1"
}

variable "app_instance_shape" {
  type        = string
  description = "[App Instance] Shape"
  default     = "VM.Standard2.2"
}

variable "num_instances" {
  default = "3"
}

variable "app_war_file" {
  type        = string
  description = "[App Instance] War file name for deployment (must live in bootstrap bucket)."
  default     = "SampleWebApp.war"
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

variable "wazuh_server" {
  type = string
  description = "[Wazuh] Server frontend port"
}