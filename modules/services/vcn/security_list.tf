resource "oci_core_security_list" "web_security_list" {
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.primary_vcn.id
  display_name        = "Web Security List"

  egress_security_rules {
    destination = var.web_security_list_egress_security_rules_destination
    protocol = var.web_security_list_egress_security_rules_protocol
    stateless = var.web_security_list_egress_security_rules_stateless
    tcp_options {
      max = var.web_security_list_egress_security_rules_tcp_options_destination_port_range_max
      min = var.web_security_list_egress_security_rules_tcp_options_destination_port_range_min
      source_port_range {
        max = var.web_security_list_egress_security_rules_tcp_options_source_port_range_max
        min = var.web_security_list_egress_security_rules_tcp_options_source_port_range_min
      }
    }
  }
  ingress_security_rules {
    protocol = var.web_security_list_ingress_security_rules_protocol
    source = var.web_security_list_ingress_security_rules_source
    description = var.web_security_list_ingress_security_rules_description
    stateless = var.web_security_list_ingress_security_rules_stateless
    tcp_options {
      max = var.web_security_list_ingress_security_rules_tcp_options_destination_port_range_max
      min = var.web_security_list_ingress_security_rules_tcp_options_destination_port_range_min
      source_port_range {
        max = var.web_security_list_ingress_security_rules_tcp_options_source_port_range_max
        min = var.web_security_list_ingress_security_rules_tcp_options_source_port_range_min
      }
    }
  }
}
