output "dns_zone" {
  value       = oci_dns_zone.zone.name
  description = "Full DNS zone name."
}