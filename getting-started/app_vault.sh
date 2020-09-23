#!/bin/bash
. caas-functions.sh
CONF_DIR="${HOME}/.oci-caas/"
CONF="${CONF_DIR}/oci-caas-pci.conf"
. $CONF

echo "We will capture three values for this application environment:"
echo "1) The Stripe secret key"
echo "2) The Stripe publishable (public) key"
echo "3) The database password to be set for the ECOM user"
echo ""
echo "If you are not ready to provide this information, you may cancel this script now, or hit <ENTER/RETURN> to continue."
echo "Note: These values are *not* logged."
echo ""
echo "<ENTER> or Quit (^C)"
read

set +x
sk=`get_response "Please enter the Stripe secret key: "`
pk=`get_response "Please enter the Stripe public key: "`
dbpw=`get_response "Please enter the ECOM user password: "`

if [[ -z ${vault_id} ]]
then
  create_vault $compartment_id "oci-caas-${ident}"

  if [[ $? -ne "0" ]]
  then
    echo "Error with vault creation. Exiting."
  else
    echo "Waiting for vault to be created"
    sleep 60
    vault_id=`get_vault_id $compartment_id "oci-caas-${ident}"`
    if [[ $? -eq 0 ]]
    then
      update_configuration $CONF vault_id $vault_id
    fi
  fi
fi

mgmt=`get_vault_mgmt $vault_id`
if [[ $? -ne 0 ]]
then
  echo "Exiting due to errors."
  exit 255
fi

create_kms_mgmt_key $compartment_id $mgmt
echo "Sleeping again just to prevent another error"
sleep 60
if [[ $? -ne 0 ]]
then
  echo "Exiting due to errors."
  exit 255
fi

mgmtkey=`get_vault_mgmt_key $compartment_id $mgmt`
if [[ $? -ne 0 ]]
then
  echo "Exiting due to errors."
  exit 255
fi

set +x
populate_vault $compartment_id $sk $pk $dbpw $vault_id $mgmtkey $ident