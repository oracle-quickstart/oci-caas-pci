resource "oci_core_security_list" "app_security_list" {
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.primary_vcn.id
  display_name        = "App Security List"

  egress_security_rules {
    destination = var.app_security_list_egress_security_rules_destination
    protocol = var.app_security_list_egress_security_rules_protocol
    stateless = var.app_security_list_egress_security_rules_stateless
    tcp_options {
      max = var.app_security_list_egress_security_rules_tcp_options_destination_port_range_max
      min = var.app_security_list_egress_security_rules_tcp_options_destination_port_range_min
      source_port_range {
        max = var.app_security_list_egress_security_rules_tcp_options_source_port_range_max
        min = var.app_security_list_egress_security_rules_tcp_options_source_port_range_min
      }
    }
  }
  ingress_security_rules {
    protocol = var.app_security_list_ingress_security_rules_protocol
    source = var.app_security_list_ingress_security_rules_source
    description = var.app_security_list_ingress_security_rules_description
    stateless = var.app_security_list_ingress_security_rules_stateless
    tcp_options {
      max = var.app_security_list_ingress_security_rules_tcp_options_destination_port_range_max
      min = var.app_security_list_ingress_security_rules_tcp_options_destination_port_range_min
      source_port_range {
        max = var.app_security_list_ingress_security_rules_tcp_options_source_port_range_max
        min = var.app_security_list_ingress_security_rules_tcp_options_source_port_range_min
      }
    }
  }
}
