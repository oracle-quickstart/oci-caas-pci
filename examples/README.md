## oci-caas-pci Example Client
In the /client directory, you can find a full example client for running this
Terraform project. Note that this client is just an example, and can be
modified to your needs.

### Required Inputs (For the OCI Provider)
These input variables are required to call the OCI provider. Depending on how
you are authenticating to OCI, other values may be required. For more information,
please see the
[Terraform provider details](https://registry.terraform.io/providers/hashicorp/oci/latest/docs),
or the
[OCI documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm)
on where to get these values.

TF_VAR | Description
------ | -----------
tenancy_ocid | OCID of your tenancy
user_ocid | OCID of the calling user
fingerprint | Fingerprint for the key pair being used
region | An OCI region

### Required Inputs (For the oci-caas-pci project)
The following inputs are required. Most of these values come from the Getting
Started process.

TF_VAR | Description
------ | -----------
compartment_ocid | OCID of the target compartment (created during Getting Started)
ssh_public_key | A public key used to grant SSH access as the opc user
frontend_ssl_certificate_id | The OCID for the SSL Certificate generated during Getting Started
bootstrap_bucket | The bucket name used (and created) during Getting Started
unique_prefix | The unique prefix used to name and tag resources
os_namespace | The Object Storage namespace
dns_domain_name | The DNS domain used during Getting Started
app_war_file | The war file name to be deployed (i.e., pci-app-1.0.0.war). This file should exist in the bootstrap_bucket.

### Generating TF_VAR Values
In the **admin-scripts** directory, the **get_tf_values.sh** script will parse the
configuration file generated during Getting Started. This provides a script that
can be copied/pasted into the environment where you call Terraform. You must run 
this from the Cloud Shell, as the same user that ran the Getting Started steps.