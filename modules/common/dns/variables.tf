variable "compartment_ocid" {}
variable "unique_prefix" {}

variable "dns_domain_name" {
  type        = string
  description = "DNS Domain where we will create a child zone."
}