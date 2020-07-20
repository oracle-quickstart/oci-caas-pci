output "vcn_id" {
  value = module.vcn.vcn_id
  description = "VCN OCID"
}

output "frontend_dns" {
  value = module.dns.frontend_dns
}