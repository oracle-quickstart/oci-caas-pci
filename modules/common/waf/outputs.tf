output "fqdn" {
  value       = oci_dns_record.waf_alias.domain
  description = "Full DNS zone name."
}