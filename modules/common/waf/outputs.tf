output "fqdn" {
  value       = oci_dns_record.waf_cname.domain
  description = "Full DNS zone name."
}