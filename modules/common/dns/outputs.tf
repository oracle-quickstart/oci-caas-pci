output "frontend_dns" {
  value = oci_dns_record.dmz_load_balancer.domain
}