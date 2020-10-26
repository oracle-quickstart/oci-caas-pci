# ---------------------------------------------------------------------------------------------------------------------
# Subnet and security list fo app server
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_subnet" "app_subnet" {
  cidr_block                 = var.app_tier_cidr_block
  display_name               = "AppSubnet"
  dns_label                  = "appsubnet"
  security_list_ids          = [oci_core_security_list.app_security_list.id]
  compartment_id             = var.compartment_ocid
  prohibit_public_ip_on_vnic = true
  vcn_id                     = var.vcn_id
  route_table_id             = var.route_table_id
  dhcp_options_id            = var.dhcp_options_id
  freeform_tags = {
    "Description" = "Application subnet"
    "Function"    = "Network space for application tier"
  }
}

resource "oci_core_security_list" "app_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "App Security List"

  freeform_tags = {
    "Description" = "Application subnet security list"
    "Function"    = "Egress and ingress rules for application tier"
  }

  egress_security_rules {
    destination = var.vcn_cidr_block
    description = "Wazuh agent communication"
    protocol    = 17
    udp_options {
      max = 1514
      min = 1514
    }
  }

  egress_security_rules {
    destination = var.egress_security_rules_destination
    protocol    = var.egress_security_rules_protocol
    stateless   = var.egress_security_rules_stateless
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
    protocol    = var.ingress_security_rules_protocol
    source      = var.vcn_cidr_block
    description = var.ingress_security_rules_description
    stateless   = var.ingress_security_rules_stateless
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