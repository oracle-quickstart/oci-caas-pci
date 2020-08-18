variable "compartment_ocid" {}
variable "vcn_id" {}
variable "route_table_id" {}
variable "dhcp_options_id" {}

variable "wazuh_tier_cidr_block" {
  type        = string
  description = "[Wazuh Tier Subnet] CIDR Block"
}

variable "wazuh_server_vcn_tcp_ports" {
  type    = list
  description = "[Wazuh Security List] Inbound TCP ports (internal to VCN)"
}

variable "wazuh_server_vcn_udp_ports" {
  type    = list
  description = "[Wazuh Security List] Inbound TCP ports (internal to VCN)"
}

variable "vcn_cidr_block" {
  type = string
  description = "[VCN] CIDR Block"
}

variable "egress_security_rules_destination" {
  type = string
  description = "[Wazuh Security List] Egress Destination"
  default = "0.0.0.0/0"
}

variable "egress_security_rules_protocol" {
  type = string
  description = "[Wazuh Security List] Egress Protocol"
  default = "6"
}

variable "egress_security_rules_stateless" {
  type = bool
  description = "[Wazuh Security List] Egress Stateless"
  default = false
}

variable "egress_security_rules_tcp_options_destination_port_range_max" {
  description = "[Wazuh Security List] Egress TCP Destination Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_tcp_options_destination_port_range_min" {
  description = "[Wazuh Security List] Egress TCP Destination Port Range Min"
  default = 1
  type = number
}

variable "egress_security_rules_tcp_options_source_port_range_max" {
  description = "[Wazuh Security List] Egress TCP Source Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_tcp_options_source_port_range_min" {
  description = "[Wazuh Security List] Egress TCP Source Port Range Min"
  default = 1
  type = number
}

variable "egress_security_rules_udp_options_destination_port_range_max" {
  description = "[Wazuh Security List] Egress UDP Destination Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_udp_options_destination_port_range_min" {
  description = "[Wazuh Security List] Egress UDP Destination Port Range Min"
  default = 1
  type = number
}

variable "egress_security_rules_udp_options_source_port_range_max" {
  description = "[Wazuh Security List] Egress UDP Source Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_udp_options_source_port_range_min" {
  description = "[Wazuh Security List] Egress UDP Source Port Range Min"
  default = 1
  type = number
}

variable "ingress_security_rules_description" {
  description = "[Wazuh Security List] Description"
  default = "Wazuh Security List - Ingress"
  type = string
}

variable "ingress_security_rules_protocol" {
  description = "[Wazuh Security List] Ingress Protocol"
  default = "6"
  type = string
}

variable "ingress_security_rules_stateless" {
  description = "[Wazuh Security List]"
  type = bool
  default = false
}

variable "ingress_security_rules_tcp_options_destination_port_range_max" {
  description = "[Wazuh Security List] Ingress TCP Destination Port Range Max"
  default = 65535
  type = number
}

variable "ingress_security_rules_tcp_options_destination_port_range_min" {
  description = "[Wazuh Security List] Ingress TCP Destination Port Range Min"
  default = 1
  type = number
}

variable "ingress_security_rules_tcp_options_source_port_range_max" {
  description = "[Wazuh Security List] Ingress TCP Source Port Range Max"
  default = 65535
  type = number
}

variable "ingress_security_rules_tcp_options_source_port_range_min" {
  description = "[Wazuh Security List] Ingress TCP Source Port Range Min"
  default = 1
  type = number
}