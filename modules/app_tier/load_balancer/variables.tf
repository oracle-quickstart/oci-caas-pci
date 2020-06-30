variable "compartment_ocid" {}
variable "vcn_id" {}
variable "app_subnet_id" {}

variable "app_server_port" {
  type = number
  description = "[App Instance] Port"
  default = 80
}