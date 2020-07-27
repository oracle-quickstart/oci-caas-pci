variable "compartment_ocid" {}

variable "certificate_display_name" {
  default = "waas_certificate"
}

variable "waas_policy_display_name" {
  default = "waas_policy"
}

variable "vcn_cidr_block" {}
variable "frontend_dns_name" {}
variable "domain_name" {}
variable "dmz_load_balancer_ip" {}
