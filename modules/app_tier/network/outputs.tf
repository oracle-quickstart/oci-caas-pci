output "app_subnet_id" {
  value = oci_core_subnet.app_subnet.id
  description = "App subnet ID"
}