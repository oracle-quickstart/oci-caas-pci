variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "app_subnet_id" {}
variable "ssh_public_key" {}
variable "region" {}
variable "unique_prefix" {}

variable "dmz_load_balancer_id" {}
variable "dmz_backendset_name" {}

variable "database_id" {}
variable "database_name" {}

variable "app_autoscaling_initial" {
  type = number
  description = "Application autoscaling instances - initial value"
  default = 2
}

variable "app_autoscaling_max" {
  type = number
  description = "Application autoscaling instances - max value"
  default = 3
}

variable "app_autoscaling_min" {
  type = number
  description = "Application autoscaling instances - minimum value"
  default = 2
}

variable "vcn_cidr_block" {
  type        = string
  description = "[VCN] CIDR Block"
}

variable "oci_caas_bootstrap_bucket" {
  type        = string
  description = "Name of the bucket created during bootstrapping."
}

variable "oci_caas_app_bootstrap_bundle" {
  type        = string
  description = "File name for the bootstrap bundle."
}

variable "cinc_version" {
  type        = string
  description = "Version of the Cinc Infra client from bootstrapping"
}

variable "tomcat_config" {
  type = map
  description = "Tomcat configuration variables"

  default = {
    http_port     = 8080
    https_port    = 8444
    shutdown_port = 8006
    version       = "8.5.68"
  }
}

variable "app_storage_gb" {
  type = number
  description = "[App Instance] Size in GB"
  default = 50
}

variable "num_paravirtualized_volumes_per_instance" {
  default = "1"
}

variable "app_instance_shape" {
  type        = string
  description = "[App Instance] Shape"
  default     = "VM.Standard2.2"
}

variable "num_instances" {
  default = "3"
}

variable "app_war_file" {
  type        = string
  description = "[App Instance] War file name for deployment (must live in bootstrap bucket)."
  default     = "SampleWebApp.war"
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

variable "wazuh_server" {
  type = string
  description = "[Wazuh] Server frontend port"
}