resource "oci_core_vcn" "primary_vcn" {
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_ocid
  display_name   = "Primary VCN"
  dns_label      = "primaryvcn"
  freeform_tags = {
    "Description" = "Primary VCN"
    "Function"    = "Primary VCN for service"
  }
}

resource "oci_core_internet_gateway" "primary_internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "PrimaryInternetGateway"
  vcn_id         = oci_core_vcn.primary_vcn.id
  freeform_tags = {
    "Description" = "Primary VCN - Internet Gateway"
    "Function"    = "Internet access into the services"
  }
}

resource "oci_core_default_route_table" "default_route_table" {
  manage_default_resource_id = oci_core_vcn.primary_vcn.default_route_table_id
  display_name               = "DefaultRouteTable"
  freeform_tags = {
    "Description" = "Primary VCN - Default route table"
    "Function"    = "Default route table for the primary VCN"
  }

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
  freeform_tags = {
    "Description" = "Primary VCN - NAT route table"
    "Function"    = "Routing table using the NAT as a default gateway"
  }

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.patching_nat_gateway.id
  }
}

resource "oci_core_nat_gateway" "patching_nat_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "PatchingNATGateway"
  vcn_id         = oci_core_vcn.primary_vcn.id
  freeform_tags = {
    "Description" = "Primary VCN - NAT Gateway"
    "Function"    = "NAT gateway used for patching and package updates"
  }
}

resource "oci_core_service_gateway" "service_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "ServiceGateway"
  vcn_id         = oci_core_vcn.primary_vcn.id
  services        {
    service_id   = lookup(data.oci_core_services.service_gateway_all_oci_services.services[0], "id")
  }
  freeform_tags = {
    "Description" = "Primary VCN - Service gateway"
    "Function"    = "Service gateway access - for OCI services"
  }
}

resource "oci_core_route_table" "service_gateway_route_table" {
  compartment_id = var.compartment_ocid
  display_name   = "ServiceGatewayRouteTable"
  vcn_id         = oci_core_vcn.primary_vcn.id
  freeform_tags = {
    "Description" = "Primary VCN - Service gateway route table"
    "Function"    = "Service gateway routing - for OCI services"
  }

  route_rules {
    destination_type  = "SERVICE_CIDR_BLOCK"
    destination       = lookup(data.oci_core_services.service_gateway_all_oci_services.services[0], "cidr_block")
    network_entity_id = oci_core_service_gateway.service_gateway.id
  }
}

data "oci_core_services" "service_gateway_all_oci_services" {
  filter {
    name   = "name"
    values = ["All [A-Za-z0-9]+ Services In Oracle Services Network"]
    regex  = true
  }
}