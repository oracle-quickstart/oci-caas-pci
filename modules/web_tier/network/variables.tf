variable "compartment_ocid" {}
variable "vcn_id" {}
variable "route_table_id" {}
variable "dhcp_options_id" {}

variable "web_tier_cidr_block" {
  type        = string
  description = "[Web Tier Subnet] CIDR Block"
}

variable "web_server_vcn_ports" {
  type    = list
  description = "[Web Security List] Inbound TCP ports (internal to VCN)"
  default = [22, 80, 443]
}

variable "vcn_cidr_block" {
  type = string
  description = "[VCN] CIDR Block"
}

variable "egress_security_rules_destination" {
  type = string
  description = "[Web Security List] Egress Destination"
  default = "0.0.0.0/0"
}

variable "egress_security_rules_protocol" {
  type = string
  description = "[Web Security List] Egress Protocol"
  default = "6"
}

variable "egress_security_rules_stateless" {
  type = bool
  description = "[Web Security List] Egress Stateless"
  default = false
}

variable "egress_security_rules_tcp_options_destination_port_range_max" {
  description = "[Web Security List] Egress TCP Destination Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_tcp_options_destination_port_range_min" {
  description = "[Web Security List] Egress TCP Destination Port Range Min"
  default = 1
  type = number
}

variable "egress_security_rules_tcp_options_source_port_range_max" {
  description = "[Web Security List] Egress TCP Source Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_tcp_options_source_port_range_min" {
  description = "[Web Security List] Egress TCP Source Port Range Min"
  default = 1
  type = number
}

variable "egress_security_rules_udp_options_destination_port_range_max" {
  description = "[Web Security List] Egress UDP Destination Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_udp_options_destination_port_range_min" {
  description = "[Web Security List] Egress UDP Destination Port Range Min"
  default = 1
  type = number
}

variable "egress_security_rules_udp_options_source_port_range_max" {
  description = "[Web Security List] Egress UDP Source Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_udp_options_source_port_range_min" {
  description = "[Web Security List] Egress UDP Source Port Range Min"
  default = 1
  type = number
}

variable "ingress_security_rules_description" {
  description = "[Web Security List] Description"
  default = "Web Security List - Ingress"
  type = string
}

variable "ingress_security_rules_protocol" {
  description = "[Web Security List] Ingress Protocol"
  default = "6"
  type = string
}

variable "ingress_security_rules_stateless" {
  description = "[Web Security List]"
  type = bool
  default = false
}

variable "ingress_security_rules_tcp_options_destination_port_range_max" {
  description = "[Web Security List] Ingress TCP Destination Port Range Max"
  default = 65535
  type = number
}

variable "ingress_security_rules_tcp_options_destination_port_range_min" {
  description = "[Web Security List] Ingress TCP Destination Port Range Min"
  default = 1
  type = number
}

variable "ingress_security_rules_tcp_options_source_port_range_max" {
  description = "[Web Security List] Ingress TCP Source Port Range Max"
  default = 65535
  type = number
}

variable "ingress_security_rules_tcp_options_source_port_range_min" {
  description = "[Web Security List] Ingress TCP Source Port Range Min"
  default = 1
  type = number
}