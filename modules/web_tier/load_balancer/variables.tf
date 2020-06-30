variable "compartment_ocid" {}
variable "vcn_id" {}
variable "web_subnet_id" {}

variable "dmz_cidr_block" {
  type        = string
  description = "[DMZ Subnet] CIDR Block"
}

variable "web_server_port" {
  type = number
  description = "[Web Instance] HTTP Port"
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

variable "egress_security_rules_udp_options_destination_port_range_max" {
  description = "[DMZ Security List] Egress UDP Destination Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_udp_options_destination_port_range_min" {
  description = "[DMZ Security List] Egress UDP Destination Port Range Min"
  default = 1
  type = number
}

variable "egress_security_rules_udp_options_source_port_range_max" {
  description = "[DMZ Security List] Egress UDP Source Port Range Max"
  default = 65535
  type = number
}

variable "egress_security_rules_udp_options_source_port_range_min" {
  description = "[DMZ Security List] Egress UDP Source Port Range Min"
  default = 1
  type = number
}

variable "ingress_security_rules_source" {
  description = "[DMZ Security List] Ingress Source"
  default = "0.0.0.0/0"
  type = string
}

variable "ingress_security_rules_description" {
  description = "[DMZ Security List] Description"
  default = "DMZ Security List - Ingress"
  type = string
}

variable "ingress_security_rules_destination" {
  description = "[DMZ Security List] Ingress Destination"
  default = "0.0.0.0/0"
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

variable "ingress_security_rules_tcp_options_destination_port_range_max" {
  description = "[DMZ Security List] Ingress TCP Destination Port Range Max"
  default = 80
  type = number
}

variable "ingress_security_rules_tcp_options_destination_port_range_min" {
  description = "[DMZ Security List] Ingress TCP Destination Port Range Min"
  default = 80
  type = number
}

variable "ingress_security_rules_udp_options_destination_port_range_max" {
  description = "[DMZ Security List] Ingress UDP Destination Port Range Max"
  default = 80
  type = number
}

variable "ingress_security_rules_udp_options_destination_port_range_min" {
  description = "[DMZ Security List] Ingress UDP Destination Port Range Min"
  default = 80
  type = number
}

variable "ingress_security_rules_udp_options_source_port_range_max" {
  description = "[DMZ Security List] Ingress UDP Source Port Range Max"
  default = 65535
  type = number
}

variable "ingress_security_rules_udp_options_source_port_range_min" {
  description = "[DMZ Security List] Ingress UDP Source Port Range Min"
  default = 1
  type = number
}
