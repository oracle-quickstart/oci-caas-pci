#!/bin/bash
admin=`dirname $0`
. ${admin}/caas-functions.sh
CONF_DIR="${HOME}/.oci-caas/"
CONF="${CONF_DIR}/oci-caas-pci.conf"
. $CONF

echo "We will capture three values for this application environment:"
echo "1) The Stripe secret key"
echo "2) The Stripe publishable key"
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
    echo -n "Waiting for vault to be created - This could take a few minutes."
    # Count of 20 - vault creation takes longer depending on the region
    count=20
    int=1
    while [[ $int -le $count ]]
    do
      echo -n "."
      sleep 30
      vault_id=`get_vault_id $compartment_id "oci-caas-${ident}"`
      if [[ -n $vault_id ]]
      then
        break
      fi
      int=`expr $int + 1`
    done
    echo ""

    if [[ -z $vault_id ]]
    then
      echo "Unable to retrieve oci vault. Exiting due to errors."
      exit 255
    else
      update_configuration $CONF vault_id $vault_id
    fi
  fi
fi

mgmt=`get_vault_mgmt $vault_id`
if [[ $? -ne 0 ]]
then
  echo "Unable to retrieve management endpoint. Exiting due to errors."
  exit 255
fi

# If we don't have a vault management key, create one
if [[ -z ${mgmtkey} ]]
then
  create_kms_mgmt_key $compartment_id $mgmt

  if [[ $? -ne "0" ]]
  then
    echo "Error with vault creation. Exiting."
  else
    echo -n "Waiting for vault management key to be created - This could take a few minutes."
    # Count of 20 - creation takes longer depending on the region
    count=20
    int=1
    while [[ $int -le $count ]]
    do
      echo -n "."
      sleep 30
      mgmtkey=`get_vault_mgmt_key $compartment_id $mgmt`
      if [[ -n $mgmtkey ]]
      then
        break
      fi
      int=`expr $int + 1`
    done
    echo ""

    if [[ -z $mgmtkey ]]
    then
      echo "Unable to retrieve vault management key. Exiting due to errors."
      exit 255
    else
      update_configuration $CONF mgmtkey $mgmtkey
    fi
  fi
fi

set +x
echo "Uploading secrets to vault - $vault_id"
populate_vault $compartment_id $sk $pk $dbpw $vault_id $mgmtkey $ident