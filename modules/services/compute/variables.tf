variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "web_subnet_id" {}
variable "ssh_public_key" {}
variable "ssh_private_key" {}
variable "region" {}

variable "web_storage_gb" {
  type = number
  description = "[Web Instance] Size in GB"
  default = 50
}

variable "num_paravirtualized_volumes_per_instance" {
  default = "1"
}

variable "web_instance_shape" {
  type = string
  description = "[Web Instance] Shape"
  default = "VM.Standard2.2"
}

variable "num_instances" {
  default = "3"
}

# Defines the number of volumes to create and attach to each instance
# NOTE: Changing this value after applying it could result in re-attaching existing volumes to different instances.
# This is a result of using 'count' variables to specify the volume and instance IDs for the volume attachment resource.
variable "num_iscsi_volumes_per_instance" {
  default = "1"
}

variable "instance_image_ocid" {
  type = map

  default = {
    # See https://docs.us-phoenix-1.oraclecloud.com/images/
    # Oracle-provided image "Oracle-Linux-7.5-2018.10.16-0"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaav3isrmykdh6r3dwicrdgpmfdv3fb3jydgh4zqpgm6yr5x3somuza"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaageeenzyuxgia726xur4ztaoxbxyjlxogdhreu3ngfj2gji3bayda"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaitzn6tdyjer7jl34h2ujz74jwy5nkbukbh55ekp6oyzwrtfa4zma"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaa32voyikkkzfxyo4xbdmadc2dmvorfxxgdhpnk6dw64fa3l4jh7wa"
  }
}
