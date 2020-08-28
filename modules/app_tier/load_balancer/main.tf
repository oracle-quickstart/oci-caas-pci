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
        min = var.app_lb_port
        max = var.app_lb_port
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
  shape          = "400Mbps"
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
    port                = var.server_port
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
    interval_ms         = "10000"
    return_code         = "200"
    timeout_in_millis   = "3000"
    retries             = "3"
  }
}

resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm     = "RSA"
  private_key_pem   = "${tls_private_key.ca.private_key_pem}"
  is_ca_certificate = true

  subject {
    common_name         = "Self Signed CA"
    organization        = "Self Signed"
    organizational_unit = "na"
  }

  validity_period_hours = 87659

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

resource "tls_private_key" "lb_private_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_cert_request" "lb_cert_request" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.lb_private_key.private_key_pem}"

  dns_names = ["localhost"]

  subject {
    common_name         = "cn"
    organization        = "org"
    country             = "country"
    organizational_unit = "ou"
  }
}

resource "tls_locally_signed_cert" "lb_cert" {
  cert_request_pem   = "${tls_cert_request.lb_cert_request.cert_request_pem}"
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${tls_private_key.lb_private_key.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = 87659

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}


# resource "tls_private_key" "example" {
#   algorithm   = "ECDSA"
#   ecdsa_curve = "P384"
# }

# resource "tls_self_signed_cert" "load_balancer_cert" {
#   key_algorithm   = "ECDSA"
#   # private_key_pem = file(var.load_balancer_cert_key)
#   private_key_pem = tls_private_key.example.private_key_pem
#   is_ca_certificate = true

#   subject {
#     common_name  = "example.com"
#     organization = "ACME Examples, Inc"
#   }

#   validity_period_hours = 12

#   allowed_uses = [
#     "key_encipherment",
#     "digital_signature",
#     "server_auth",
#     "client_auth",
#     "cert_signing"
#   ]
# }

# resource "oci_load_balancer_certificate" "delete_me" {
#   #Required
#   certificate_name = "test_cert_name"
#   load_balancer_id = oci_load_balancer.dmz_load_balancer.id

#   #Optional
#   #ca_certificate = "${var.certificate_ca_certificate}"
#   # passphrase = "${var.certificate_passphrase}"
#   # private_key = tls_private_key.example.private_key_pem
#   # public_certificate = tls_self_signed_cert.load_balancer_cert.cert_pem
#   # ca_certificate = tls_self_signed_cert.load_balancer_cert.cert_pem
#   private_key = tls_private_key.lb_private_key.private_key_pem
#   public_certificate = tls_locally_signed_cert.lb_cert.cert_pem
#   ca_certificate = tls_self_signed_cert.ca.cert_pem

#   # lifecycle {
#   #     create_before_destroy = true
#   # }
# }

resource "oci_load_balancer_certificate" "lb_cert" {
  #Required
  certificate_name = "lb_cert"
  load_balancer_id = oci_load_balancer.dmz_load_balancer.id

  #Optional
  #ca_certificate = "${var.certificate_ca_certificate}"
  # passphrase = "${var.certificate_passphrase}"
  # private_key = tls_private_key.example.private_key_pem
  # public_certificate = tls_self_signed_cert.load_balancer_cert.cert_pem
  # ca_certificate = tls_self_signed_cert.load_balancer_cert.cert_pem
  private_key = tls_private_key.lb_private_key.private_key_pem
  public_certificate = tls_locally_signed_cert.lb_cert.cert_pem
  ca_certificate = tls_self_signed_cert.ca.cert_pem

  # lifecycle {
  #     create_before_destroy = true
  # }
}

# resource "oci_load_balancer_listener" "lb_app_listener" {
#   load_balancer_id         = oci_load_balancer.app_load_balancer.id
#   name                     = "https"
#   default_backend_set_name = oci_load_balancer_backend_set.lb-app-bes.name
#   port                     = var.app_lb_port
#   protocol                 = "HTTP"

#   ssl_configuration {
#     certificate_name = oci_load_balancer_certificate.test_certificate.certificate_name
#   }
# }

resource "oci_load_balancer_listener" "lb_dmz_listener" {
  load_balancer_id         = oci_load_balancer.dmz_load_balancer.id
  name                     = "https"
  default_backend_set_name = oci_load_balancer_backend_set.lb-dmz-bes.name
  port                     = 443
  protocol                 = "HTTP"
  ssl_configuration {
    certificate_name        = oci_load_balancer_certificate.lb_cert.certificate_name
    verify_peer_certificate = false
  }
}