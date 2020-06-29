variable "compartment_ocid" {}
variable "vcn_id" {}
variable "route_table_id" {}
variable "dhcp_options_id" {}

variable "web_security_list_egress_security_rules_destination" {
  type = string
  description = "[Web Security List] Egress Destination"
  default = "0.0.0.0/0"
}

variable "web_security_list_egress_security_rules_protocol" {
  type = string
  description = "[Web Security List] Egress Protocol"
  default = "6"
}

variable "web_security_list_egress_security_rules_stateless" {
  type = bool
  description = "[Web Security List] Egress Stateless"
  default = false
}

variable "web_security_list_egress_security_rules_tcp_options_destination_port_range_max" {
  description = "[Web Security List] Egress TCP Destination Port Range Max"
  default = 65535
  type = number
}

variable "web_security_list_egress_security_rules_tcp_options_destination_port_range_min" {
  description = "[Web Security List] Egress TCP Destination Port Range Min"
  default = 1
  type = number
}

variable "web_security_list_egress_security_rules_tcp_options_source_port_range_max" {
  description = "[Web Security List] Egress TCP Source Port Range Max"
  default = 65535
  type = number
}

variable "web_security_list_egress_security_rules_tcp_options_source_port_range_min" {
  description = "[Web Security List] Egress TCP Source Port Range Min"
  default = 1
  type = number
}

variable "web_security_list_egress_security_rules_udp_options_destination_port_range_max" {
  description = "[Web Security List] Egress UDP Destination Port Range Max"
  default = 65535
  type = number
}

variable "web_security_list_egress_security_rules_udp_options_destination_port_range_min" {
  description = "[Web Security List] Egress UDP Destination Port Range Min"
  default = 1
  type = number
}

variable "web_security_list_egress_security_rules_udp_options_source_port_range_max" {
  description = "[Web Security List] Egress UDP Source Port Range Max"
  default = 65535
  type = number
}

variable "web_security_list_egress_security_rules_udp_options_source_port_range_min" {
  description = "[Web Security List] Egress UDP Source Port Range Min"
  default = 1
  type = number
}

variable "web_security_list_ingress_security_rules_source" {
  description = "[Web Security List] Ingress Source"
  default = "0.0.0.0/0"
  type = string
}

variable "web_security_list_ingress_security_rules_description" {
  description = "[Web Security List] Description"
  default = "Web Security List - Ingress"
  type = string
}

variable "web_security_list_ingress_security_rules_destination" {
  description = "[Web Security List] Ingress Destination"
  default = "0.0.0.0/0"
  type = string
}

variable "web_security_list_ingress_security_rules_protocol" {
  description = "[Web Security List] Ingress Protocol"
  default = "6"
  type = string
}

variable "web_security_list_ingress_security_rules_stateless" {
  description = "[Web Security List]"
  type = bool
  default = false
}

variable "web_security_list_ingress_security_rules_tcp_options_destination_port_range_max" {
  description = "[Web Security List] Ingress TCP Destination Port Range Max"
  default = 65535
  type = number
}

variable "web_security_list_ingress_security_rules_tcp_options_destination_port_range_min" {
  description = "[Web Security List] Ingress TCP Destination Port Range Min"
  default = 1
  type = number
}

variable "web_security_list_ingress_security_rules_tcp_options_source_port_range_max" {
  description = "[Web Security List] Ingress TCP Source Port Range Max"
  default = 65535
  type = number
}

variable "web_security_list_ingress_security_rules_tcp_options_source_port_range_min" {
  description = "[Web Security List] Ingress TCP Source Port Range Min"
  default = 1
  type = number
}

variable "web_security_list_ingress_security_rules_udp_options_destination_port_range_max" {
  description = "[Web Security List] Ingress UDP Destination Port Range Max"
  default = 65535
  type = number
}

variable "web_security_list_ingress_security_rules_udp_options_destination_port_range_min" {
  description = "[Web Security List] Ingress UDP Destination Port Range Min"
  default = 1
  type = number
}

variable "web_security_list_ingress_security_rules_udp_options_source_port_range_max" {
  description = "[Web Security List] Ingress UDP Source Port Range Max"
  default = 65535
  type = number
}

variable "web_security_list_ingress_security_rules_udp_options_source_port_range_min" {
  description = "[Web Security List] Ingress UDP Source Port Range Min"
  default = 1
  type = number
}