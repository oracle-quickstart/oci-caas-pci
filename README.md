# OCI CAAS PCI
Welcome

## Requirements
To successfully build and manage this project, you will need to meet the requirements.

### OCI Console & Cloud Shell
The initialization process utilizes the OCI Cloud Shell, so you'll need
access to the OCI Console and [Cloud Shell](https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/cloudshellintro.htm).

### Externally registerred DNS domain
To support public facing SSL certificates and the
[OCI WAF](https://docs.cloud.oracle.com/en-us/iaas/Content/WAF/Concepts/overview.htm),
you will need an
externally registerred DNS zone with SOA records pointing to OCI managed DNS zone.
For more information see [DNS Setup](#dns-setup).

### External software requirements
* Terraform >= 0.12.x
* Chef >= 16.x
* Authenticator app (I use FreeOTP, but any popular authenticator app should work)
* SSH client
* SQL client (I have used SQL Developer)
* Git

### Stripe API keys
To utilize Stripe, you will need to have access to a pair of
[Stripe Publishable & Secret keys](https://stripe.com/docs/keys).
These are stored in an OCI Vault and then used by the application server upon bootstrapping.

### Install acme.sh on your OCI Cloud Shell
We utilize [acme.sh](https://github.com/acmesh-official/acme.sh)
for SSL certificate creation. You should install this within your 
OCI Cloud Shell environment. Our installer checks for the default installation path in
**$HOME/.acme.sh**

Follow the (instructions here)(https://github.com/acmesh-official/acme.sh).
You will need to pass the --force option to install, which will bypass the
check for cron.

## DNS Setup
In the tenancy you plan on using, you will need to
(create a new compartment)[https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm] -
this compartment is separate from the one we will create for the application. We do 
this to be able to manage DNS across multiple compartments.

Once your compartment is created, you need to create a *Primary* DNS Zone in
the console under
Networking -> DNS Management -> Zones - or via the CLI/API.

Further reading:
https://docs.cloud.oracle.com/en-us/iaas/Content/DNS/Tasks/managingdnszones.htm

Update your DNS Registrar nameservers to the ones provided by Oracle in the console.
These will look similar to ns4.p68.dns.oraclecloud.net - and you'll want to use all
four addresses that are provided.

_Why we do this_

We automate DNS record creation using the OCI DNS service, including the registration steps
with Let's Encrypt (via ACME and a txt record for validation). The records and
certificates are used for connections to the OCI WAF/WAAS endpoint. Currently,
these are not optional components.

For example, we can have a my-admin compartment, and in there a DNS Zone called
"pci-demo.cloud". When we build the SSL certificate and verify with ACME, we
create _acme-challenge.pci-demo.cloud. Later in the build process, in a new compartment,
we create a DNS zone for (example) foo.pci-demo.cloud - and then create records
inside of that zone through Terraform.

## Getting started with OCI CAAS
To begin, you'll need to log into the OCI Console and launch the Cloud Shell.
This is the icon in the top-right corner - it looks like this: *>_*

See [Getting Started with Cloud Shell](https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/devcloudshellgettingstarted.htm)
for detailed instructions on using the Cloud Shell.

Clone the repository from Github:
```
git clone <URL TO REPO GOES HERE>
```

The scripts we're going to run are contained within the admin-scripts directory,
so you can change to that directory or run the upcoming commands with the path included.
```
cd oci-caas-pci/admin-scripts
```

### Initialize CAAS Environment
The first script creates a new compartment, object storage bucket, and caches 
dependencies into the bucket.
```
./caas-init.sh
```

### Populate the application vault
The next script you need to run takes in secret values, creates a new vault,
and stores new vault objects. For this to run successfully, you'll need three values:
1. The Stripe API publishable key
1. The Stripe API secret key
1. Generate a password which will be used for the ECOM DB user

```
./app_vault.sh
```

### Configuration file
For troubleshooting, overriding values, and resetting values - the configuration these
scripts rely on is at **$HOME/.oci-caas/oci-caas-pci.conf**

## Generate Public SSL Certificate
This step should be run after the Getting Started section, before the Terraform steps.

From the root of this repo, use the `admin-scripts/ssl_certificate.sh` to generate
a new wildcard certificate for the zone that you will be managing. This script will
utilize the DNS zone you created earlier to create a validation txt record and 
then upload the new certificate and private key to the OCI WAF/WAAS certificate store.

```
admin-scripts/ssl_certificate.sh -d <your domain>
```

Optional: You can override the Compartment OCID,
if you want to create multiple sites using the same
certificate. Specify the admin compartment you created the DNS zone in earlier. This
is ideal if you want to create multiple compartments (like dev, test, staging)
in the same tenancy.

```
admin-scripts/ssl_certificate.sh -d <your domain> -o <compartment ocid>
```

This will echo the certificate OCID back to the terminal, and store it for later use in the
configuration file. You'll need this value for the Terraform stack.

### Certificate renewal
The certificate you created is **only valid for 90 days**. To renew the certificate, you can
run the same process again - ideally every 2 months. This creates a new certificate
store entry, which can then be passed onto Terraform for a new update.

Once the WAF has been updated via Terraform, the new certificate is active.

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

## Database Audit Logs
OCI Data Safe should already be enabled via Terraform, but you'll need to turn on specific audit features you may require.

https://docs.cloud.oracle.com/en-us/iaas/data-safe/doc/activity-auditing-overview.html


## Important Variables
The **admin-scripts/get_tf_values.sh** script will parse the configuration file
created during initialization. Run this and you'll have a good starting point for 
moving onto Terraform.

```
./get_tf_values.sh
```

## Important Variables
Variables to define
* _oci_caas_bootstrap_bucket_: Object store bucket name where bootstrap code was deployed to (see Getting Started)