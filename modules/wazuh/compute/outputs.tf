output "wazuh_server_ip" {
  value = oci_core_instance.wazuh_server.private_ip
}

output "wazuh_password" {
  value = random_password.wazuh_password.result
}