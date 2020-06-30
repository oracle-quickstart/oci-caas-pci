output "vcn_id" {
  value = oci_core_vcn.primary_vcn.id
}

output "dhcp_options_id" {
  value = oci_core_vcn.primary_vcn.default_dhcp_options_id
  description = "DHCP Options OCID"
}

output "default_route_table_id" {
  value = oci_core_default_route_table.default_route_table.id
  description = "Default route"
}

output "nat_route_table_id" {
  value = oci_core_route_table.nat_route_table.id
  description = "NAT route table"
}

output "nat_gateway_id" {
  value = oci_core_nat_gateway.patching_nat_gateway.id
  description = "NAT gateway"
}