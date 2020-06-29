variable "compartment_ocid" {}

resource "oci_core_vcn" "primary_vcn" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "Primary VCN"
  dns_label      = "primaryvcn"
}

resource "oci_core_internet_gateway" "primary_internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "PrimaryInternetGateway"
  vcn_id         = oci_core_vcn.primary_vcn.id
}

resource "oci_core_default_route_table" "default_route_table" {
  manage_default_resource_id = oci_core_vcn.primary_vcn.default_route_table_id
  display_name               = "DefaultRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.primary_internet_gateway.id
  }
}

resource "oci_core_route_table" "nat_route_table" {
  compartment_id = var.compartment_ocid
  display_name   = "PatchingNATRouteTable"
  vcn_id         = oci_core_vcn.primary_vcn.id

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.patching_nat_gateway.id
  }
}

resource "oci_core_nat_gateway" "patching_nat_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "PatchingNATGateway"
  vcn_id         = oci_core_vcn.primary_vcn.id
}

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