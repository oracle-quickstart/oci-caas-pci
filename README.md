# OCI CAAS PCI
Welcome

## Getting started with OCI CAAS
Getting started...

## How to call this module
Terraform code to call the module - including required variables. Following the instructions at
https://www.terraform.io/docs/providers/oci/index.html for where to get these values, and more information
on the OCI provider.
``` 
# Values are examples and need to be changed.
module "oci-caas-pci" {
  # This can be a relative path or URL
  source = "../oci-caas-pci"

  # OCID of the target compartment
  compartment_ocid = ocid1.compartment.oc1..aaaaaaaaba3pv6wkcr4jqae5f44n2b2m2yt2j6rx32uzr4h25vqstifsfdsq

  # OCID of the target tenancy
  tenancy_ocid     = ocid1.tenancy.oc1..aaaaaaaaba3pv6wkcr4jqae5f44n2b2m2yt2j6rx32uzr4h25vqstifsfdsq

  # OCID of your user
  user_ocid        = ocid1.user.oc1..aaaaaaaaba3pv6wkcr4jqae5f44n2b2m2yt2j6rx32uzr4h25vqstifsfdsq

  # Fingerprint for your user key
  fingerprint      = d1:b2:32:53:d3:5f:cf:68:2d:6f:8b:5f:77:8f:07:13

  # Target region for deployment
  region           = us-phoenix-1

  # Path to your ssh public key
  ssh_public_key   = /home/user/.ssh/id_rsa.pub
}
```

## Important Variables
Variables to define
* _caas_bucket_name_: Object store bucket name where bootstrap code was deployed to (see Getting Started)