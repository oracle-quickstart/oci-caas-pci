output "vcn_id" {
  value       = module.vcn.vcn_id
  description = "VCN OCID"
}

output "frontend_fqdn" {
  value       = module.waf.fqdn
  description = "FQDN to the WAF endpoint"
}

output "bastion_ip" {
  value = module.bastion.bastion_ip
}

output "wazuh_ip" {
  value = module.wazuh.wazuh_server_ip
}

output "wazuh_password" {
  value = module.wazuh.wazuh_password
}