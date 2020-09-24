output "vcn_id" {
  value       = module.vcn.vcn_id
  description = "VCN OCID"
}

output "frontend_fqdn" {
  value       = module.waf.fqdn
  description = "FQDN to the WAF endpoint"
}

output "otp_one" {
  value = module.bastion.otp_one
}

output "otp_two" {
  value = module.bastion.otp_two
}

output "otp_three" {
  value = module.bastion.otp_three
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