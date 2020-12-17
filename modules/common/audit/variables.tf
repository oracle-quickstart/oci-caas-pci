variable "tenancy_ocid" {}

variable "audit_retention_period" {
  type = number
  description = "Audit Retention Period"
  default = 365
}