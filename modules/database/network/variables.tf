variable "compartment_ocid" {}
variable "vcn_id" {}
variable "route_table_id" {}
variable "dhcp_options_id" {}

variable "vcn_cidr_block" {
  type        = string
  description = "[VCN] CIDR Block"
}

variable "database_cidr_block" {
  type        = string
  description = "[Database Subnet] CIDR Block"
}

variable "egress_security_rules_destination" {
  type = string
  description = "[Database Security List] Egress Destination"
  default = "0.0.0.0/0"
}

variable "egress_security_rules_protocol" {
  type = string
  description = "[Database Security List] Egress Protocol"
  default = "6"
}

variable "egress_security_rules_stateless" {
  type = bool
  description = "[Database Security List] Egress Stateless"
  default = false
}

variable "egress_security_rules_tcp_options_destination_port_range_max" {
  description = "[Database Security List] Egress TCP Destination Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_tcp_options_destination_port_range_min" {
  description = "[Database Security List] Egress TCP Destination Port Range Min"
  default = 1
  type = number
}

variable "egress_security_rules_tcp_options_source_port_range_max" {
  description = "[Database Security List] Egress TCP Source Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_tcp_options_source_port_range_min" {
  description = "[Database Security List] Egress TCP Source Port Range Min"
  default = 1
  type = number
}

variable "egress_security_rules_udp_options_destination_port_range_max" {
  description = "[Database Security List] Egress UDP Destination Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_udp_options_destination_port_range_min" {
  description = "[Database Security List] Egress UDP Destination Port Range Min"
  default = 1
  type = number
}

variable "egress_security_rules_udp_options_source_port_range_max" {
  description = "[Database Security List] Egress UDP Source Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_udp_options_source_port_range_min" {
  description = "[Database Security List] Egress UDP Source Port Range Min"
  default = 1
  type = number
}

variable "ingress_security_rules_source" {
  description = "[Database Security List] Ingress Source"
  default = "0.0.0.0/0"
  type = string
}

variable "ingress_security_rules_description" {
  description = "[Database Security List] Description"
  default = "Database Security List - Ingress"
  type = string
}

variable "ingress_security_rules_destination" {
  description = "[Database Security List] Ingress Destination"
  default = "0.0.0.0/0"
  type = string
}

variable "ingress_security_rules_protocol" {
  description = "[Database Security List] Ingress Protocol"
  default = "6"
  type = string
}

variable "ingress_security_rules_stateless" {
  description = "[Database Security List]"
  type = bool
  default = false
}

variable "ingress_security_rules_tcp_options_destination_port_range_max" {
  description = "[Database Security List] Ingress TCP Destination Port Range Max"
  default = 65535
  type = number
}

variable "ingress_security_rules_tcp_options_destination_port_range_min" {
  description = "[Database Security List] Ingress TCP Destination Port Range Min"
  default = 1
  type = number
}

variable "ingress_security_rules_tcp_options_source_port_range_max" {
  description = "[Database Security List] Ingress TCP Source Port Range Max"
  default = 65535
  type = number
}

variable "ingress_security_rules_tcp_options_source_port_range_min" {
  description = "[Database Security List] Ingress TCP Source Port Range Min"
  default = 1
  type = number
}

variable "ingress_security_rules_udp_options_destination_port_range_max" {
  description = "[Database Security List] Ingress UDP Destination Port Range Max"
  default = 65535
  type = number
}

variable "ingress_security_rules_udp_options_destination_port_range_min" {
  description = "[Database Security List] Ingress UDP Destination Port Range Min"
  default = 1
  type = number
}

variable "ingress_security_rules_udp_options_source_port_range_max" {
  description = "[Database Security List] Ingress UDP Source Port Range Max"
  default = 65535
  type = number
}

variable "ingress_security_rules_udp_options_source_port_range_min" {
  description = "[Database Security List] Ingress UDP Source Port Range Min"
  default = 1
  type = number
}