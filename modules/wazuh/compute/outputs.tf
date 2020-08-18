output "wazuh_server_ip" {
  value = oci_core_instance.wazuh_server.private_ip
}