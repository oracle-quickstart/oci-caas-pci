output "dmz_load_balancer_id" {
  value = oci_load_balancer.dmz_load_balancer.id
}

output "frontend_load_balancer_ips" {
  value = oci_load_balancer.dmz_load_balancer.ip_address_details
}

output "dmz_backendset_name" {
  value  = oci_load_balancer_backend_set.lb-dmz-bes.name
}