# ---------------------------------------------------------------------------------------------------------------------
# Subnet and security list fo database
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_subnet" "database_subnet" {
  cidr_block                 = var.database_cidr_block
  display_name               = "DatabaseSubnet"
  dns_label                  = "databasesubnet"
  security_list_ids          = [oci_core_security_list.database_security_list.id]
  compartment_id             = var.compartment_ocid
  prohibit_public_ip_on_vnic = true
  vcn_id                     = var.vcn_id
  route_table_id             = var.route_table_id
  dhcp_options_id            = var.dhcp_options_id
}

resource "oci_core_network_security_group" "database_security_group" {
    compartment_id = var.compartment_ocid
    display_name = "ATPSecurityGroup"
    vcn_id = var.vcn_id
}

resource "oci_core_network_security_group_security_rule" "database_security_egress_group_rule" {
    network_security_group_id = oci_core_network_security_group.database_security_group.id
    direction = "EGRESS"
    protocol = "6"
    destination = var.vcn_cidr_block
    destination_type = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "database_security_ingress_group_rule" {
    network_security_group_id = oci_core_network_security_group.database_security_group.id
    direction = "INGRESS"
    protocol = "6"
    source = var.vcn_cidr_block
    source_type = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            max = 1522
            min = 1522
        }
    }
}

resource "oci_core_security_list" "database_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "Database Security List"

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
    source      = var.ingress_security_rules_source
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
