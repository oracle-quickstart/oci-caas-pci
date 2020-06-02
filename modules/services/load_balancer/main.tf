resource "oci_core_security_list" "dmz_security_list" {
  compartment_id      = var.compartment_ocid
  vcn_id              = var.vcn_id
  display_name        = "DMZ Security List"

  egress_security_rules {
    destination = var.dmz_security_list_egress_security_rules_destination
    protocol = var.dmz_security_list_egress_security_rules_protocol
    stateless = var.dmz_security_list_egress_security_rules_stateless
    tcp_options {
      max = var.dmz_security_list_egress_security_rules_tcp_options_destination_port_range_max
      min = var.dmz_security_list_egress_security_rules_tcp_options_destination_port_range_min
      source_port_range {
        max = var.dmz_security_list_egress_security_rules_tcp_options_source_port_range_max
        min = var.dmz_security_list_egress_security_rules_tcp_options_source_port_range_min
      }
    }
  }

  ingress_security_rules {
    protocol = var.dmz_security_list_ingress_security_rules_protocol
    source = var.dmz_security_list_ingress_security_rules_source
    description = var.dmz_security_list_ingress_security_rules_description
    stateless = var.dmz_security_list_ingress_security_rules_stateless
    tcp_options {
      max = var.dmz_security_list_ingress_security_rules_tcp_options_destination_port_range_max
      min = var.dmz_security_list_ingress_security_rules_tcp_options_destination_port_range_min
    }
  }
}

resource "oci_core_subnet" "dmz_subnet" {
  cidr_block          = "10.1.2.0/24"
  display_name        = "DMZ Subnet"
  dns_label           = "dmzsubnet"
  security_list_ids   = [oci_core_security_list.dmz_security_list.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = var.vcn_id
}

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

output "dmz_load_balancer_id" {
  value = oci_load_balancer.dmz_load_balancer.id
}

output "dmz_backendset_name" {
  value  = oci_load_balancer_backend_set.lb-dmz-bes.name
}

# resource "oci_load_balancer_backend" "lb-dmz-be" {
#   load_balancer_id = oci_load_balancer.dmz_load_balancer.id
#   backendset_name  = oci_load_balancer_backend_set.lb-dmz-bes.name
#   ip_address       = oci_core_instance.compute_instance1.private_ip
#   port             = 8080
#   backup           = false
#   drain            = false
#   offline          = false
#   weight           = 1
# }
