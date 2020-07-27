output "vcn_id" {
  value       = module.vcn.vcn_id
  description = "VCN OCID"
}

output "frontend_fqdn" {
  value       = module.waf.fqdn
  description = "FQDN to the WAF endpoint"
}