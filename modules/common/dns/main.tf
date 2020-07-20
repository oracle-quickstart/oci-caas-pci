# ---------------------------------------------------------------------------------------------------------------------
# Random id used to prevent name collisions
# ---------------------------------------------------------------------------------------------------------------------
resource "random_id" "zone_name" {
  byte_length = 2
}

# ---------------------------------------------------------------------------------------------------------------------
# Create child zone
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_dns_zone" "zone" {
  compartment_id = var.compartment_ocid
  name = "${random_id.zone_name.hex}.${var.dns_domain_name}"
  zone_type = "PRIMARY"
}

# ---------------------------------------------------------------------------------------------------------------------
# Register front-end A record based on the DMZ load balancer IP address
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_dns_record" "dmz_load_balancer" {
  compartment_id  = var.compartment_ocid
  zone_name_or_id = oci_dns_zone.zone.name
  domain = "frontend.${oci_dns_zone.zone.name}"
  rtype = "A"
  rdata = var.frontend_ips[0].ip_address
  ttl   = 30
}