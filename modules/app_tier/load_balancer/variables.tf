variable "compartment_ocid" {}
variable "vcn_id" {}
variable "app_subnet_id" {}

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

variable "all_waf_cidr_blocks" {
  type = list
  description = "[DMZ Security List] Ingress CIDR blocks from Oracle WAF"
  default = [
    "192.29.64.0/20",
    "147.154.208.0/21",
    "147.154.224.0/19",
    "138.1.224.0/19",
    "138.1.208.0/20",
    "138.1.80.0/20",
    "138.1.16.0/20",
    "130.35.112.0/22",
    "147.154.80.0/21",
    "147.154.64.0/20",
    "147.154.0.0/18",
    "138.1.48.0/21",
    "192.29.56.0/21",
    "130.35.232.0/21",
    "192.29.48.0/21",
    "130.35.224.0/22",
    "192.29.32.0/21",
    "130.35.192.0/19",
    "192.29.16.0/21",
    "130.35.176.0/20",
    "192.29.144.0/21",
    "130.35.144.0/20",
    "192.29.128.0/21",
    "130.35.120.0/21",
    "130.35.96.0/20",
    "192.29.0.0/20",
    "130.35.64.0/19",
    "130.35.48.0/20",
    "147.154.192.0/20",
    "147.154.128.0/18",
    "130.35.16.0/20",
    "138.1.192.0/20",
    "138.1.160.0/19",
    "192.29.96.0/20",
    "138.1.104.0/22",
    "138.1.96.0/21",
    "138.1.64.0/20",
    "138.1.40.0/21",
    "147.154.96.0/19",
    "138.1.128.0/19",
    "138.1.0.0/20",
    "138.1.32.0/21",
    "130.35.240.0/20",
    "130.35.128.0/20",
    "130.35.0.0/20",
    "199.195.6.0/23",
    "198.181.48.0/21",
    "192.69.118.0/23",
    "205.147.88.0/21",
    "66.254.103.241/32",
    "192.157.19.0/24",
    "192.157.18.0/24",
    "205.147.95.0/24"
  ]
}