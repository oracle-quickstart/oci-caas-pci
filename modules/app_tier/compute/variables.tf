variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "app_subnet_id" {}
variable "ssh_public_key" {}
variable "region" {}
variable "app_load_balancer_id" {}
variable "app_backendset_name" {}

variable "vcn_cidr_block" {
  type = string
  description = "[VCN] CIDR Block"
}

variable "tomcat_http_port" {
  type        = number
  description = "HTTP port for Tomcat server"
  default     = 8080
}

variable "app_server_port" {
  type = number
  description = "[App Instance] HTTP Port"
  default = 80
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
  type = string
  description = "[App Instance] Shape"
  default = "VM.Standard2.2"
}

variable "num_instances" {
  default = "3"
}

variable "instance_image_ocid" {
  type = map

  default = {
    # See https://docs.us-phoenix-1.oraclecloud.com/images/
    # Oracle-Autonomous-Linux-7.x
    # Oracle-Autonomous-Linux-7.8-2020.04-0
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaax6mhsb3xey2gaz3ftkjwta5qkyr5se7va22sspbxghonldndph6a"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaajb2c3ew4peg7lrlzjwpam3vksrouvuysooh663nvqm5acb6tl4ya"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaat27bladiw33zqkw2amhg35tq4gqxdwerhsoabskqgcqpq7bhh52q"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaa4r6gjlmo33yscossp7h6w6j3ry3eh2mwppsjnh26w3xakumvnrpa"
  }
}
