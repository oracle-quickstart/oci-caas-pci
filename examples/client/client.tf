# oci-caas-pci example client

# Connection strings
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "region" {}

# Required values to build the project
variable "compartment_ocid" {}
variable "ssh_public_key" {}
variable "app_war_file" {}
variable "frontend_ssl_certificate_id" {}
variable "unique_prefix" {}
variable "os_namespace" {}
variable "bootstrap_bucket" {}
variable "dns_domain_name" {}

# Load the OCI provider
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  region           = var.region
}

# Call the main oci-caas-pci project
module "oci-caas-pci" {
  #source                      = "../oci-caas-pci"
  source                      = "/PATH/TO/oci-caas-pci"
  compartment_ocid            = var.compartment_ocid
  tenancy_ocid                = var.tenancy_ocid
  user_ocid                   = var.user_ocid
  fingerprint                 = var.fingerprint
  region                      = var.region
  ssh_public_key              = var.ssh_public_key
  app_war_file                = var.app_war_file
  frontend_ssl_certificate_id = var.frontend_ssl_certificate_id
  os_namespace                = var.os_namespace
  unique_prefix               = var.unique_prefix
  oci_caas_bootstrap_bucket   = var.bootstrap_bucket
  dns_domain_name             = var.dns_domain_name
  database_password           = random_password.initial_database_password.result
}

# For first creaton of the database. Password can be changed/managed outside of TF
resource "random_password" "initial_database_password" {
  length = 16
  special = true
  override_special = "_%@"
}

output "Initial_database_password" {
  description = "Initial database password"
  value = random_password.initial_database_password.result
}

output "frontend" {
  value = "https://${module.oci-caas-pci.frontend_fqdn}"
}

output "bastion_ip" {
  value = module.oci-caas-pci.bastion_ip
}

output "wazuh_ip" {
  value = module.oci-caas-pci.wazuh_ip
}

output "wazuh_password" {
  value = module.oci-caas-pci.wazuh_password
}