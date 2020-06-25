variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "web_subnet_id" {}
variable "bastion_subnet_id" {}
variable "ssh_public_key" {}
variable "region" {}
variable "dmz_load_balancer_id" {}
variable "dmz_backendset_name" {}

variable "bastion_enabled" {
  type = bool
  description = "[Bastion Instance] Enabled (true/false)?"
  default = true
}

variable "web_server_port" {
  type = number
  description = "[Web Instance] HTTP Port"
  default = 80
}

variable "web_storage_gb" {
  type = number
  description = "[Web Instance] Size in GB"
  default = 50
}

variable "num_paravirtualized_volumes_per_instance" {
  default = "1"
}

variable "bastion_instance_shape" {
  type = string
  description = "[Bastion Instance] Shape"
  default = "VM.Standard2.2"
}

variable "web_instance_shape" {
  type = string
  description = "[Web Instance] Shape"
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
