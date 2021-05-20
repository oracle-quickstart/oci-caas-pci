#!/bin/bash
admin=`dirname $0`
. ${admin}/caas-functions.sh
CONF_DIR="${HOME}/.oci-caas/"
CONF="${CONF_DIR}/oci-caas-pci.conf"
. $CONF

home_region=$(oci iam region-subscription list | jq '.data[] | select(."is-home-region" == true) | ."region-name"' --raw-output);

echo "export TF_VAR_tenancy_ocid=\"$tenancy_ocid\""
echo "export TF_VAR_region=\"$home_region\""
echo "export TF_VAR_os_namespace=\"$os_namespace\""
echo "export TF_VAR_unique_prefix=\"$ident\""
echo "export TF_VAR_compartment_ocid=\"$compartment_id\""

echo "# These should be changed per environment, but keep the values unless you have better ones"
echo "export TF_VAR_frontend_ssl_certificate_id=\"$frontend_ssl_certificate_id\""

echo "export TF_VAR_app_war_file=\""pci-ecommerce-0.5.0.war"\""
echo "export TF_VAR_ssh_public_key=\"~/.ssh/id_rsa.pub\""
echo "export TF_VAR_ssh_private_key=\"~/.ssh/id_rsa\""
echo "export TF_VAR_bootstrap_bucket=\"$caas_bucket\""

echo "# These values need to be set still:"
echo "export TF_VAR_user_ocid=''"
echo "export TF_VAR_fingerprint=''"