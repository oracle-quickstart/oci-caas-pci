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
On your management workstation, you will need the following:
* Terraform >= 0.12.x
* SSH client
* SQL client (I have used SQL Developer)
* Git

For two-factor authentication:
* Authenticator app (I use FreeOTP, but any popular authenticator app should work)

### Stripe API keys
To utilize Stripe, you will need to have access to a pair of
[Stripe Publishable & Secret keys](https://stripe.com/docs/keys).
These are stored in an OCI Vault and then used by the application server upon bootstrapping.

### Install acme.sh on your OCI Cloud Shell
We utilize [acme.sh](https://github.com/acmesh-official/acme.sh)
for SSL certificate creation. You should install this within your 
OCI Cloud Shell environment. Our installer checks for the default installation path in
**$HOME/.acme.sh**

Follow the [instructions here](https://github.com/acmesh-official/acme.sh).
You will need to pass the --force option to install, which will bypass the
check for cron.

## DNS Setup
In the tenancy you plan on using, you will need to
[create a new compartment](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Tasks/managingcompartments.htm) -
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
git clone https://github.com/oracle-quickstart/oci-caas-pci.git
```

Note: All of the scripts we're going to run are contained within the *admin-scripts* directory.

### Initialize CAAS Environment
The first script creates a new compartment, object storage bucket, and caches 
dependencies into the bucket. See the below note on setting a Unique Identifier,
or move on with the script and accept the defaults.

```
admin-scripts/caas-init.sh
```

#### Unique Identifier (environment naming)
By default, we will generate a 4 character string to use for uniquely naming resources,
including the compartment, DNS zones, vault resources, and much more. This string
can be overridden before initialization - This identifier can not be changed later.

To set a custom identifier, set a value for **OVERRIDE_IDENT** before
running caas-init.sh
```
export OVERRIDE_IDENT="dev1"
```

### Populate the application vault
The next script you need to run takes in secret values, creates a new vault,
and stores new vault objects. For this to run successfully, you'll need three values:
1. The Stripe API publishable key
1. The Stripe API secret key
1. Generate a password which will be used for the ECOM DB user

```
admin-scripts/app_vault.sh
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

## How to call this Terraform module
See the **/examples** diretory for an example client, and descriptions for
important variables.

## Terraform Variables
The **admin-scripts/get_tf_values.sh** script will parse the configuration file
created during initialization. Run this and you'll have a good starting point for 
moving onto Terraform.

```
admin-scripts/get_tf_values.sh
```

## Things To Do After Terraform
Once the Terraform initialization is complete, there are a couple more steps. At
the time of this writing, these things can not be managed through Terraform.
These are required for compliance reasons.

### Database Audit Logs
OCI Data Safe should already be enabled via Terraform, but you'll need to turn on specific audit features you may require.

https://docs.cloud.oracle.com/en-us/iaas/data-safe/doc/activity-auditing-overview.html

### Setting up WAF / WAAS rules
By default, no rules are enabled on the WAF, and you'll need to run a script to update them in bulk.

```
admin-scripts/activate_waf_rules.sh <WAF OCID>
```

### First time Bastion pin
In order to log into the Bastion the first time, you will need your private SSH key (public key should have been provided as an input
for Terraform). With that, you'll be prompted for a "One-time password (OATH) for `opc'" - the default value is: **560000**

Immediately scan the barcode using your authenticator of choice, or you will lose access to this host. If you can't log in, you will have to
terminate the bastion and recreate it via Terraform.

### Wazuh
This stack deploys a [Wazuh](https://wazuh.com/) instance for security monitoring, threat detection, integrity monitoring, and more. You can log
in by using an SSH tunnel through the Bastion. The wazuh IP address and password will be in the output of Terraform. The username is: _wazuh_