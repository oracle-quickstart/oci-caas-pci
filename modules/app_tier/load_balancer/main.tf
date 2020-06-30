# ---------------------------------------------------------------------------------------------------------------------
# Network resources used for load balancing
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_load_balancer" "app_load_balancer" {
  shape          = "100Mbps"
  compartment_id = var.compartment_ocid
  is_private = true

  subnet_ids = [
    var.app_subnet_id
  ]

  display_name = "app-load-balancer"
}

resource "oci_load_balancer_backend_set" "lb-app-bes" {
  name             = "lb-app-bes"
  load_balancer_id = oci_load_balancer.app_load_balancer.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = var.app_server_port
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
    interval_ms         = "10000"
    return_code         = "200"
    timeout_in_millis   = "3000"
    retries             = "3"
  }
}

resource "oci_load_balancer_listener" "lb_app_listener" {
  load_balancer_id         = oci_load_balancer.app_load_balancer.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.lb-app-bes.name
  port                     = var.app_server_port
  protocol                 = "HTTP"
}