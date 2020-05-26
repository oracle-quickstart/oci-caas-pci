variable "compartment_ocid" {}
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "ssh_public_key" {}
variable "ssh_private_key" {}

variable "app_security_list_egress_security_rules_destination" {
  type = string
  description = "[App Security List] Egress Destination"
  default = "0.0.0.0/0"
}

variable "app_security_list_egress_security_rules_protocol" {
  type = string
  description = "[App Security List] Egress Protocol"
  default = "6"
}

variable "app_security_list_egress_security_rules_stateless" {
  type = bool
  description = "[App Security List] Egress Stateless"
  default = false
}

variable "app_security_list_egress_security_rules_tcp_options_destination_port_range_max" {
  description = "[App Security List] Egress TCP Destination Port Range Max"
  default = 65535
  type = number
}

variable "app_security_list_egress_security_rules_tcp_options_destination_port_range_min" {
  description = "[App Security List] Egress TCP Destination Port Range Min"
  default = 1
  type = number
}

variable "app_security_list_egress_security_rules_tcp_options_source_port_range_max" {
  description = "[App Security List] Egress TCP Source Port Range Max"
  default = 65535
  type = number
}

variable "app_security_list_egress_security_rules_tcp_options_source_port_range_min" {
  description = "[App Security List] Egress TCP Source Port Range Min"
  default = 1
  type = number
}

variable "app_security_list_egress_security_rules_udp_options_destination_port_range_max" {
  description = "[App Security List] Egress UDP Destination Port Range Max"
  default = 65535
  type = number
}

variable "app_security_list_egress_security_rules_udp_options_destination_port_range_min" {
  description = "[App Security List] Egress UDP Destination Port Range Min"
  default = 1
  type = number
}

variable "app_security_list_egress_security_rules_udp_options_source_port_range_max" {
  description = "[App Security List] Egress UDP Source Port Range Max"
  default = 65535
  type = number
}

variable "app_security_list_egress_security_rules_udp_options_source_port_range_min" {
  description = "[App Security List] Egress UDP Source Port Range Min"
  default = 1
  type = number
}

variable "app_security_list_ingress_security_rules_source" {
  description = "[App Security List] Ingress Source"
  default = "0.0.0.0/0"
  type = string
}

variable "app_security_list_ingress_security_rules_description" {
  description = "[App Security List] Description"
  default = "App Security List - Ingress"
  type = string
}

variable "app_security_list_ingress_security_rules_destination" {
  description = "[App Security List] Ingress Destination"
  default = "0.0.0.0/0"
  type = string
}

variable "app_security_list_ingress_security_rules_protocol" {
  description = "[App Security List] Ingress Protocol"
  default = "6"
  type = string
}

variable "app_security_list_ingress_security_rules_stateless" {
  description = "[App Security List]"
  type = bool
  default = false
}

variable "app_security_list_ingress_security_rules_tcp_options_destination_port_range_max" {
  description = "[App Security List] Ingress TCP Destination Port Range Max"
  default = 65535
  type = number
}

variable "app_security_list_ingress_security_rules_tcp_options_destination_port_range_min" {
  description = "[App Security List] Ingress TCP Destination Port Range Min"
  default = 1
  type = number
}

variable "app_security_list_ingress_security_rules_tcp_options_source_port_range_max" {
  description = "[App Security List] Ingress TCP Source Port Range Max"
  default = 65535
  type = number
}

variable "app_security_list_ingress_security_rules_tcp_options_source_port_range_min" {
  description = "[App Security List] Ingress TCP Source Port Range Min"
  default = 1
  type = number
}

variable "app_security_list_ingress_security_rules_udp_options_destination_port_range_max" {
  description = "[App Security List] Ingress UDP Destination Port Range Max"
  default = 65535
  type = number
}

variable "app_security_list_ingress_security_rules_udp_options_destination_port_range_min" {
  description = "[App Security List] Ingress UDP Destination Port Range Min"
  default = 1
  type = number
}

variable "app_security_list_ingress_security_rules_udp_options_source_port_range_max" {
  description = "[App Security List] Ingress UDP Source Port Range Max"
  default = 65535
  type = number
}

variable "app_security_list_ingress_security_rules_udp_options_source_port_range_min" {
  description = "[App Security List] Ingress UDP Source Port Range Min"
  default = 1
  type = number
}
