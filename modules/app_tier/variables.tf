variable "compartment_ocid" {}
variable "vcn_id" {}
variable "route_table_id" {}
variable "dhcp_options_id" {}
variable "region" {}
variable "ssh_public_key" {}
variable "tenancy_ocid" {}
variable "database_id" {}
variable "database_name" {}
variable "unique_prefix" {}

variable "app_tier_cidr_block" {
  type        = string
  description = "[App tier Subnet] CIDR Block"
}

variable "dmz_cidr_block" {
  type        = string
  description = "[DMZ Subnet] CIDR Block"
}

variable "vcn_cidr_block" {
  type = string
  description = "[VCN] CIDR Block"
}

variable "app_lb_port" {
  type = number
  description = "[App Load Balancer] Port"
  default = 443
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

variable "app_war_file" {
  type        = string
  description = "[App Instance] War file name for deployment (must live in bootstrap bucket)."
  default     = "SampleWebApp.war"
}

variable "tomcat_config" {
  type = map
  description = "Tomcat configuration variables"

  default = {
    http_port     = 8080
    https_port    = 8444
    shutdown_port = 8006
    version       = "8.5.60"
  }
}

variable "wazuh_tier_cidr_block" {
  type = string
  description = "[Wazuh] CIDR block"
}

variable "wazuh_server" {
  type = string
  description = "[Wazuh] Server frontend port"
}

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