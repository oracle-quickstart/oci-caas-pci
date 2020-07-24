# ---------------------------------------------------------------------------------------------------------------------
# List of all WAF edge subnets
# Currently unused, due to an error in the data. See var.all_waf_cidr_blocks for workaround.
# ---------------------------------------------------------------------------------------------------------------------
# data "oci_waas_edge_subnets" "test_edge_subnets" {}

# ---------------------------------------------------------------------------------------------------------------------
# Network resources used for load balancing
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_security_list" "dmz_egress_security_list" {
  compartment_id      = var.compartment_ocid
  vcn_id              = var.vcn_id
  display_name        = "DMZ Security List - Egress"

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
}

# ---------------------------------------------------------------------------------------------------------------------
# Ingress security rules
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_security_list" "dmz_ingress_security_list" {
  compartment_id      = var.compartment_ocid
  vcn_id              = var.vcn_id
  display_name        = "DMZ Security List - Ingress"

  # Dynamic list of ingress CIDR blocks
  dynamic ingress_security_rules {
    for_each = var.all_waf_cidr_blocks
    # Commented out due to bug in WAF CIDR block list
    # for_each = data.oci_waas_edge_subnets.test_edge_subnets.edge_subnets
    content {
      protocol    = var.ingress_security_rules_protocol
      # Commented out due to bug in WAF CIDR block list
      # source      = ingress_security_rules.value.cidr
      source      = ingress_security_rules.value
      description = var.ingress_security_rules_description
      stateless   = var.ingress_security_rules_stateless
      tcp_options {
        max = var.ingress_security_rules_tcp_options_destination_port_range_max
        min = var.ingress_security_rules_tcp_options_destination_port_range_min
      }
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DMZ Subnet
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_subnet" "dmz_subnet" {
  cidr_block          = var.dmz_cidr_block
  display_name        = "DMZ Subnet"
  dns_label           = "dmzsubnet"
  security_list_ids   = [oci_core_security_list.dmz_egress_security_list.id, oci_core_security_list.dmz_ingress_security_list.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = var.vcn_id
}
 
# ---------------------------------------------------------------------------------------------------------------------
# DMZ load balancer, backend set, and listener
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_load_balancer" "dmz_load_balancer" {
  shape          = "100Mbps"
  compartment_id = var.compartment_ocid

  subnet_ids = [
    oci_core_subnet.dmz_subnet.id,
  ]

  display_name = "dmz-load-balancer"
}

resource "oci_load_balancer_backend_set" "lb-dmz-bes" {
  name             = "lb-dmz-bes"
  load_balancer_id = oci_load_balancer.dmz_load_balancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = var.web_server_port
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
    interval_ms         = "10000"
    return_code         = "200"
    timeout_in_millis   = "3000"
    retries             = "3"
  }
}

resource "oci_load_balancer_listener" "lb_dmz_listener" {
  load_balancer_id         = oci_load_balancer.dmz_load_balancer.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.lb-dmz-bes.name
  port                     = 80
  protocol                 = "HTTP"
}