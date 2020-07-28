variable "compartment_ocid" {}
variable "vcn_id" {}
variable "route_table_id" {}
variable "dhcp_options_id" {}
variable "app_lb_port" {}

variable "tomcat_config" {
  type        = map
  description = "Tomcat configuration variables"
}

variable "vcn_cidr_block" {
  type        = string
  description = "[VCN] CIDR Block"
}

variable "app_tier_cidr_block" {
  type        = string
  description = "[App Tier Subnet] CIDR Block"
}

variable "egress_security_rules_destination" {
  type = string
  description = "[App Security List] Egress Destination"
  default = "0.0.0.0/0"
}

variable "egress_security_rules_protocol" {
  type = string
  description = "[App Security List] Egress Protocol"
  default = "6"
}

variable "egress_security_rules_stateless" {
  type = bool
  description = "[App Security List] Egress Stateless"
  default = false
}

variable "egress_security_rules_tcp_options_destination_port_range_max" {
  description = "[App Security List] Egress TCP Destination Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_tcp_options_destination_port_range_min" {
  description = "[App Security List] Egress TCP Destination Port Range Min"
  default = 1
  type = number
}

variable "egress_security_rules_tcp_options_source_port_range_max" {
  description = "[App Security List] Egress TCP Source Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_tcp_options_source_port_range_min" {
  description = "[App Security List] Egress TCP Source Port Range Min"
  default = 1
  type = number
}

variable "egress_security_rules_udp_options_destination_port_range_max" {
  description = "[App Security List] Egress UDP Destination Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_udp_options_destination_port_range_min" {
  description = "[App Security List] Egress UDP Destination Port Range Min"
  default = 1
  type = number
}

variable "egress_security_rules_udp_options_source_port_range_max" {
  description = "[App Security List] Egress UDP Source Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_udp_options_source_port_range_min" {
  description = "[App Security List] Egress UDP Source Port Range Min"
  default = 1
  type = number
}

variable "ingress_security_rules_description" {
  description = "[App Security List] Description"
  default = "App Security List - Ingress"
  type = string
}

variable "ingress_security_rules_protocol" {
  description = "[App Security List] Ingress Protocol"
  default = "6"
  type = string
}

variable "ingress_security_rules_stateless" {
  description = "[App Security List]"
  type = bool
  default = false
}

variable "ingress_security_rules_tcp_options_destination_port_range_max" {
  description = "[App Security List] Ingress TCP Destination Port Range Max"
  default = 65535
  type = number
}

variable "ingress_security_rules_tcp_options_destination_port_range_min" {
  description = "[App Security List] Ingress TCP Destination Port Range Min"
  default = 1
  type = number
}

variable "ingress_security_rules_tcp_options_source_port_range_max" {
  description = "[App Security List] Ingress TCP Source Port Range Max"
  default = 65535
  type = number
}

variable "ingress_security_rules_tcp_options_source_port_range_min" {
  description = "[App Security List] Ingress TCP Source Port Range Min"
  default = 1
  type = number
}

variable "ingress_security_rules_udp_options_destination_port_range_max" {
  description = "[App Security List] Ingress UDP Destination Port Range Max"
  default = 65535
  type = number
}

variable "ingress_security_rules_udp_options_destination_port_range_min" {
  description = "[App Security List] Ingress UDP Destination Port Range Min"
  default = 1
  type = number
}

variable "ingress_security_rules_udp_options_source_port_range_max" {
  description = "[App Security List] Ingress UDP Source Port Range Max"
  default = 65535
  type = number
}

variable "ingress_security_rules_udp_options_source_port_range_min" {
  description = "[App Security List] Ingress UDP Source Port Range Min"
  default = 1
  type = number
}