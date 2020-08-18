# ---------------------------------------------------------------------------------------------------------------------
# Bastion subnet and security list
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_subnet" "bastion_subnet" {
  cidr_block          = var.bastion_cidr_block
  display_name        = "BastionSubnet"
  dns_label           = "bastionsubnet"
  security_list_ids   = [oci_core_security_list.bastion_security_list.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = var.vcn_id
  route_table_id      = var.route_table_id
  dhcp_options_id     = var.dhcp_options_id
}

resource "oci_core_security_list" "bastion_security_list" {
  compartment_id      = var.compartment_ocid
  vcn_id              = var.vcn_id
  display_name        = "Bastion Security List"

  egress_security_rules {
    destination = var.wazuh_tier_cidr_block
    description = "Wazuh agent communication"
    protocol    = 17
    udp_options {
      max = 1514
      min = 1514
    }
  }

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

output "subnet_id" {
  value = oci_core_subnet.bastion_subnet.id
  description = "Bastion subnet ID"
}