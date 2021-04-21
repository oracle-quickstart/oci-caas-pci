output "fqdn" {
  value       = oci_dns_rrset.waf_alias.domain
  description = "Full DNS zone name."
}