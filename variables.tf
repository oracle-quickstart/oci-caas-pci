variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_public_key" {}

variable "unique_prefix" {}
variable "os_namespace" {}

variable "frontend_dns_name" {
  type        = string
  description = "DNS frontend name (i.e. www)"
  default     = "www"
}

variable "dns_domain_name" {
  type        = string
  description = "[DNS] Domain name where new child domain will be created"
}

variable "primary_vcn_cidr_block" {
  type        = string
  description = "[Primary VCN] CIDR Block"
  default     = "10.1.0.0/16"
}

variable "dmz_subnet_cidr_block" {
  type        = string
  description = "[DMZ Subnet] CIDR Block"
  default     = "10.1.21.0/24"
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

variable "wazuh_tier_subnet_cidr_block" {
  type        = string
  description = "[Wazuh Tier Subnet] CIDR Block"
  default     = "10.1.6.0/24"
}

variable "database_password" {
  type        = string
  description = "database password"
}

variable "database_listener_port" {
  description = "[Database] Listener port"
  type        = number
  default     = 1522
}

variable "oci_caas_bootstrap_bucket" {
  type        = string
  description = "Name of the bucket created during bootstrapping."
}

variable "oci_caas_app_bootstrap_bundle" {
  type        = string
  description = "File name for the bootstrap bundle."
  default     = "app_cookbooks.tar.gz"
}

variable "oci_caas_bastion_bootstrap_bundle" {
  type        = string
  description = "File name for the bootstrap bundle."
  default     = "bastion_cookbooks.tar.gz"
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

variable "app_war_file" {
  type        = string
  description = "[App Instance] War file name for deployment (must live in bootstrap bucket)."
  default     = "SampleWebApp.war"
}

variable "wazuh_server_vcn_tcp_ports" {
  type        = list
  description = "[Wazuh Security List] Inbound TCP ports (internal to VCN)"
  default     = [22, 443, 1515]
}

variable "wazuh_server_vcn_udp_ports" {
  type        = list
  description = "[Wazuh Security List] Inbound UDP ports (internal to VCN)"
  default     = [1514]
}

variable "frontend_ssl_certificate_id" {
  type = string
  description = "SSL Certificate OCID for frontend WAF/WAAS"
}