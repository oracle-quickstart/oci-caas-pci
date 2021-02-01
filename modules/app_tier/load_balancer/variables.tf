variable "compartment_ocid" {}
variable "vcn_id" {}
variable "app_subnet_id" {}
variable "app_lb_port" {}

variable "dmz_cidr_block" {
  type        = string
  description = "[DMZ Subnet] CIDR Block"
}

variable "server_port" {
  type = number
  description = "[App Instance] Server Port"
  default = 80
}

variable "egress_security_rules_destination" {
  type = string
  description = "[DMZ Security List] Egress Destination"
  default = "0.0.0.0/0"
}

variable "egress_security_rules_protocol" {
  type = string
  description = "[DMZ Security List] Egress Protocol"
  default = "6"
}

variable "egress_security_rules_stateless" {
  type = bool
  description = "[DMZ Security List] Egress Stateless"
  default = false
}

variable "egress_security_rules_tcp_options_destination_port_range_max" {
  description = "[DMZ Security List] Egress TCP Destination Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_tcp_options_destination_port_range_min" {
  description = "[DMZ Security List] Egress TCP Destination Port Range Min"
  default = 1
  type = number
}

variable "egress_security_rules_tcp_options_source_port_range_max" {
  description = "[DMZ Security List] Egress TCP Source Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_tcp_options_source_port_range_min" {
  description = "[DMZ Security List] Egress TCP Source Port Range Min"
  default = 1
  type = number
}

variable "ingress_security_rules_description" {
  description = "[DMZ Security List] Description"
  default = "DMZ Security List - Ingress"
  type = string
}

variable "ingress_security_rules_protocol" {
  description = "[DMZ Security List] Ingress Protocol"
  default = "6"
  type = string
}

variable "ingress_security_rules_stateless" {
  description = "[DMZ Security List]"
  type = bool
  default = false
}