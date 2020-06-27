resource "oci_core_subnet" "web_subnet" {
  cidr_block          = "10.1.1.0/24"
  display_name        = "WebSubnet"
  dns_label           = "websubnet"
  security_list_ids   = [oci_core_security_list.web_security_list.id]
  compartment_id      = var.compartment_ocid
  prohibit_public_ip_on_vnic = true
  vcn_id              = var.vcn_id
  route_table_id      = var.route_table_id
  dhcp_options_id     = var.dhcp_options_id
}

resource "oci_core_security_list" "web_security_list" {
  compartment_id      = var.compartment_ocid
  vcn_id              = var.vcn_id
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

output "web_subnet_id" {
  value = oci_core_subnet.web_subnet.id
  description = "Web subnet ID"
}