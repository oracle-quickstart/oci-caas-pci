variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "database_subnet_id" {}
variable "vcn_id" {}
variable "ssh_public_key" {}
variable "region" {}
variable "database_security_group_id" {}

variable "database_password" {
    type = string
    description = "[Database] Admin password"
}
variable "database_cpu_core_count" {
    type = number
    description = "[Database] CPU Core Count"
    default = 1
}
variable "database_data_storage_size_in_tbs" {
    type = number
    description = "[Database] Storage in TBs"
    default = 1
}
variable "database_db_name" {
    type = string
    description = "[Database] DB Name"
    default = "atpdb1"
}
variable "database_db_version" {
    type = string
    description = "[Database] Oracle Version"
    default = "19c"
}
variable "database_display_name" {
    type = string
    description = "[Database] Display Name"
    default = "ATP"
}
variable "database_license_model" {
    type = string
    description = "[Database] License model"
    default = "LICENSE_INCLUDED"
}