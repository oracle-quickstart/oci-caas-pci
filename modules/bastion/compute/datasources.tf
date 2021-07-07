data "oci_core_images" "autonomous_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Autonomous Linux"
  operating_system_version = var.instance_operating_system_version
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}