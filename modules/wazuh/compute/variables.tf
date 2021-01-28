variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "subnet_id" {}
variable "ssh_public_key" {}
variable "region" {}

variable "wazuh_backup_bucket_name" {
  type = string
  description = "Bucket name for Wazuh backups"
}

variable "oci_caas_bootstrap_bucket" {
  type        = string
  description = "Name of the bucket created during bootstrapping."
}

variable "wazuh_server_port" {
  type = number
  description = "[Wazuh Instance] HTTP Port"
  default = 80
}

variable "wazuh_storage_gb" {
  type = number
  description = "[Wazuh Instance] Size in GB"
  default = 500
}

variable "num_paravirtualized_volumes_per_instance" {
  default = "1"
}

variable "wazuh_instance_shape" {
  type = string
  description = "[Wazuh Instance] Shape"
  default = "VM.Standard2.2"
}

variable "num_instances" {
  default = "1"
}

variable "vcn_cidr_block" {
  type = string
  description = "[VCN] CIDR Block"
}

variable "instance_image_ocid" {
  type = map

  default = {
    # See https://docs.us-phoenix-1.oraclecloud.com/images/
    # Oracle-Autonomous-Linux-7.9
    # Oracle-Autonomous-Linux-7.9-2021.01-0
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaadzbjqqwjzgl7yweoiqbltuh2y7kb4alzyuv4k3mambxpcpiicj3a"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaauitscop5dhasbqkegaju56brylkckgi2wfecct2cuvn4xk33d2wq"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaamv56sieig6vgu7jqg5pber3oe6xwrszjvfdbl2veka5dwrdgomea"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaay6ffduwdwuip5phglsoqrbztdxs5kq2qjt3rgqowksoltnxcjdea"
  }
}
