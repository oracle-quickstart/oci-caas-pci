variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "database_subnet_id" {}
variable "ssh_public_key" {}
variable "region" {}
variable "database_security_group_id" {}

variable "database_password" {
    type = string
    description = "database admin password"
}
variable "database_cpu_core_count" {
    type = number
    description = ""
    default = 1
}
variable "database_data_storage_size_in_tbs" {
    type = number
    description = ""
    default = 1
}
variable "database_db_name" {
    type = string
    description = ""
    default = "atpdb1"
}
variable "database_db_version" {
    type = string
    description = ""
    default = "19c"
}
variable "database_display_name" {
    type = string
    description = ""
    default = "ATP"
}
variable "database_license_model" {
    type = string
    description = ""
    default = "LICENSE_INCLUDED"
}