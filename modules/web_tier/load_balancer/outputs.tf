output "dmz_load_balancer_id" {
  value = oci_load_balancer.dmz_load_balancer.id
}

output "dmz_backendset_name" {
  value  = oci_load_balancer_backend_set.lb-dmz-bes.name
}