# ---------------------------------------------------------------------------------------------------------------------
# Random id used to prevent name collisions
# ---------------------------------------------------------------------------------------------------------------------
# resource "random_id" "zone_name" {
#   byte_length = 2
# }

# ---------------------------------------------------------------------------------------------------------------------
# Create child zone
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_dns_zone" "zone" {
  compartment_id = var.compartment_ocid
  name = "${var.unique_prefix}.${var.dns_domain_name}"
  zone_type = "PRIMARY"

  freeform_tags = {
    "Description" = "DNS Zone"
    "Function"    = "Provide DNS resolution"
  }
}