output "database_subnet_id" {
  value = oci_core_subnet.database_subnet.id
  description = "database subnet ID"
}

output "database_security_group_id" {
  value = oci_core_network_security_group.database_security_group.id
}