variable "compartment_ocid" {}
variable "vcn_id" {}
variable "route_table_id" {}
variable "dhcp_options_id" {}

variable "vcn_cidr_block" {
  description = "[VCN] CIDR Block"
  type        = string
}

variable "database_cidr_block" {
  description = "[Database Subnet] CIDR Block"
  type        = string
}

variable "database_listener_port" {
  description = "[Database] Listener port"
  type        = number
  default     = 1522
}

variable "egress_security_rules_protocol" {
  description = "[Database Security List] Egress Protocol"
  type        = string
  default     = "6"
}

variable "egress_security_rules_stateless" {
  description = "[Database Security List] Egress Stateless"
  type        = bool
  default     = false
}

variable "egress_security_rules_tcp_options_destination_port_range_max" {
  description = "[Database Security List] Egress TCP Destination Port Range Max"
  type        = number
  default     = 65535
}

variable "egress_security_rules_tcp_options_destination_port_range_min" {
  description = "[Database Security List] Egress TCP Destination Port Range Min"
  type        = number
  default     = 1
}

variable "egress_security_rules_tcp_options_source_port_range_max" {
  description = "[Database Security List] Egress TCP Source Port Range Max"
  type        = number
  default     = 65535
}

variable "egress_security_rules_tcp_options_source_port_range_min" {
  description = "[Database Security List] Egress TCP Source Port Range Min"
  type        = number
  default     = 1
}

variable "egress_security_rules_udp_options_destination_port_range_max" {
  description = "[Database Security List] Egress UDP Destination Port Range Max"
  type        = number
  default     = 65535
}

variable "egress_security_rules_udp_options_destination_port_range_min" {
  description = "[Database Security List] Egress UDP Destination Port Range Min"
  type        = number
  default     = 1
}

variable "egress_security_rules_udp_options_source_port_range_max" {
  description = "[Database Security List] Egress UDP Source Port Range Max"
  type        = number
  default     = 65535
}

variable "egress_security_rules_udp_options_source_port_range_min" {
  description = "[Database Security List] Egress UDP Source Port Range Min"
  type        = number
  default     = 1
}

variable "ingress_security_rules_description" {
  description = "[Database Security List] Description"
  type        = string
  default     = "Database Security List - Ingress"
}

variable "ingress_security_rules_protocol" {
  description = "[Database Security List] Ingress Protocol"
  type        = string
  default     = "6"
}

variable "ingress_security_rules_stateless" {
  description = "[Database Security List]"
  type        = bool
  default     = false
}

variable "ingress_security_rules_tcp_options_destination_port_range_max" {
  description = "[Database Security List] Ingress TCP Destination Port Range Max"
  type        = number
  default     = 65535
}

variable "ingress_security_rules_tcp_options_destination_port_range_min" {
  description = "[Database Security List] Ingress TCP Destination Port Range Min"
  type        = number
  default     = 1
}

variable "ingress_security_rules_tcp_options_source_port_range_max" {
  description = "[Database Security List] Ingress TCP Source Port Range Max"
  type        = number
  default     = 65535
}

variable "ingress_security_rules_tcp_options_source_port_range_min" {
  description = "[Database Security List] Ingress TCP Source Port Range Min"
  type        = number
  default     = 1
}

variable "ingress_security_rules_udp_options_destination_port_range_max" {
  description = "[Database Security List] Ingress UDP Destination Port Range Max"
  type        = number
  default     = 65535
}

variable "ingress_security_rules_udp_options_destination_port_range_min" {
  description = "[Database Security List] Ingress UDP Destination Port Range Min"
  type        = number
  default     = 1
}

variable "ingress_security_rules_udp_options_source_port_range_max" {
  description = "[Database Security List] Ingress UDP Source Port Range Max"
  type        = number
  default     = 65535
}

variable "ingress_security_rules_udp_options_source_port_range_min" {
  description = "[Database Security List] Ingress UDP Source Port Range Min"
  type        = number
  default     = 1
}