output "app_load_balancer_id" {
  value = oci_load_balancer.app_load_balancer.id
}

output "app_backendset_name" {
  value  = oci_load_balancer_backend_set.lb-app-bes.name
}

output "app_subnet_id" {
  value = oci_core_subnet.app_subnet.id
  description = "App subnet ID"
}