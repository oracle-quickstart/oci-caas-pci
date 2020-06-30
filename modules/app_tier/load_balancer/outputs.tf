output "app_load_balancer_id" {
  value = oci_load_balancer.app_load_balancer.id
}

output "app_backendset_name" {
  value  = oci_load_balancer_backend_set.lb-app-bes.name
}