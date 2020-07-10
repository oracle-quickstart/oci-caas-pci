# ---------------------------------------------------------------------------------------------------------------------
# Subnet and security list fo web server
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_subnet" "web_subnet" {
  cidr_block          = var.web_tier_cidr_block
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
    destination = var.egress_security_rules_destination
    protocol = var.egress_security_rules_protocol
    stateless = var.egress_security_rules_stateless
    tcp_options {
      max = var.egress_security_rules_tcp_options_destination_port_range_max
      min = var.egress_security_rules_tcp_options_destination_port_range_min
      source_port_range {
        max = var.egress_security_rules_tcp_options_source_port_range_max
        min = var.egress_security_rules_tcp_options_source_port_range_min
      }
    }
  }
  ingress_security_rules {
    protocol = var.ingress_security_rules_protocol
    source = var.ingress_security_rules_source
    description = var.ingress_security_rules_description
    stateless = var.ingress_security_rules_stateless
    tcp_options {
      max = var.ingress_security_rules_tcp_options_destination_port_range_max
      min = var.ingress_security_rules_tcp_options_destination_port_range_min
      source_port_range {
        max = var.ingress_security_rules_tcp_options_source_port_range_max
        min = var.ingress_security_rules_tcp_options_source_port_range_min
      }
    }
  }
}

output "web_subnet_id" {
  value = oci_core_subnet.web_subnet.id
  description = "Web subnet ID"
}