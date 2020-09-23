#!/bin/bash

. caas-functions.sh
CONF_DIR="${HOME}/.oci-caas/"
CONF="${CONF_DIR}/oci-caas-pci.conf"

if [[ ! -f $CONF ]]
then
  mkdir -p $CONF_DIR
  initialize_configuration $CONF
fi

# Read in previously stored (or newly emptied) values
echo "Using configuration file: $CONF"
. $CONF

# Generate new identifier, with an optional first-time override
if [[ -n ${ident} ]]
then
  echo "Using existing ID string: $ident"
else
  if [[ -n ${OVERRIDE_IDENT} ]]
  then
    ident=$OVERRIDE_IDENT
  else
    ident=`cat /dev/urandom | tr -dc 'a-z0-9' | head -c 4`
  fi

  echo "Using ID string: $ident"
  update_configuration $CONF ident $ident
fi

if [[ -z ${tenancy_ocid} ]]
then
  tenancy_ocid=`get_root_compartment_ocid`
  
  if [[ $? -eq 0 ]]
  then
    update_configuration $CONF tenancy_ocid $tenancy_ocid
  else
    echo "Error retrieving tenancy OCID. Exiting." 1>&2
    exit 255
  fi
fi

# Create compartment if it does not exist
if [[ -n ${compartment_id} ]]
then
  echo "Using existing compartment with OCID: ${compartment_id}"
else
  echo -n "Creating new compartment... "
  compartment_id=`create_compartment "oci-caas-${ident}" $tenancy_ocid "oci-caas compartment - ${ident}"`
  if [[ $? -eq 0 ]]
  then
    echo "Compartment OCID: ${compartment_id}"
    update_configuration $CONF compartment_id $compartment_id
  else
    echo "Error while creating compartment: Exiting"
    exit 255
  fi
fi


if [[ -n ${caas_bucket} ]]
then
  echo "Using existing bootstrap bucket with name: $caas_bucket"
else
  echo -n "Creating new bootstrap bucket... "
  caas_bucket="oci-caas-${ident}"
  create_bucket $compartment_id $caas_bucket
  if [[ $? -eq 0 ]]
  then
    echo "Bucket name: $caas_bucket"
    update_configuration $CONF caas_bucket $caas_bucket
  else
    echo "Error while creating compartment: Exiting"
    exit 255
  fi
fi

if [[ -n ${caas_bucket} ]]
then
  os_namespace=`get_bucket_namespace $tenancy_ocid`
  update_configuration $CONF os_namespace $os_namespace
fi

cache_packages $os_namespace $caas_bucket
if [[ $? -ne 0 ]]
then
  echo "Error while uploading packages to object store bucket."
  exit 255
fi

echo "Time to set up application vault. Run app_vault.sh next."

echo "Manually verify SSL certificate deployment."

echo "TF values to be used in client caller:"
bash get_tf_values.sh

cleanup_logs