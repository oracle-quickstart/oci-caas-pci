output "frontend_dns" {
  value = oci_dns_record.dmz_load_balancer.domain
}

output "dns_zone" {
  value = oci_dns_zone.zone.name
}