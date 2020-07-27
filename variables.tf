variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_public_key" {}

variable "frontend_dns_name" {
  type        = string
  description = "DNS frontend name (i.e. www)"
  default     = "www"
}
variable "caas_bucket_name" {
  type        = string
  description = "[OCI CaaS] Bucket name"
  default     = "chef-cookbooks"
}

variable "dns_domain_name" {
  type        = string
  description = "[DNS] Domain name where new child domain will be created"
  default     = "oci-caas.cloud"
}

variable "primary_vcn_cidr_block" {
  type        = string
  description = "[Primary VCN] CIDR Block"
  default     = "10.1.0.0/16"
}

variable "dmz_subnet_cidr_block" {
  type        = string
  description = "[DMZ Subnet] CIDR Block"
  default     = "10.1.2.0/24"
}

variable "web_tier_subnet_cidr_block" {
  type        = string
  description = "[Web Tier Subnet] CIDR Block"
  default     = "10.1.1.0/24"
}

variable "bastion_subnet_cidr_block" {
  type        = string
  description = "[Bastion Subnet] CIDR Block"
  default     = "10.1.3.0/24"
}

variable "app_tier_subnet_cidr_block" {
  type        = string
  description = "[App Tier Subnet] CIDR Block"
  default     = "10.1.4.0/24"
}

variable "database_subnet_cidr_block" {
  type        = string
  description = "[Database Subnet] CIDR Block"
  default     = "10.1.5.0/24"
}

variable "database_password" {
  type        = string
  description = "database password"
}

variable "oci_caas_bootstrap_bucket" {
  type        = string
  description = "Name of the bucket created during bootstrapping."
  default     = "chef-cookbooks"
}

variable "oci_caas_app_bootstrap_bundle" {
  type        = string
  description = "File name for the bootstrap bundle."
  default     = "app_cookbooks.tar.gz"
}

variable "chef_version" {
  type        = string
  description = "Version of the Chef Infra client from bootstrapping"
  default     = "16.1.16-1"
}

variable "tomcat_config" {
  type = map
  description = "Tomcat configuration variables"

  default = {
    http_port     = 8080
    https_port    = 8444
    shutdown_port = 8006
    version       = "8.5.57"
  }
}