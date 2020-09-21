variable "compartment_ocid" {}
variable "os_namespace" {
  type = string
  description = "Namespace for object storage"
}

variable "unique_prefix" {
  type = string
  description = "Unique prefix to prevent naming collisions"
}

variable "bucket_suffix" {
  type = string
  description = "Bucket name suffix"
}
