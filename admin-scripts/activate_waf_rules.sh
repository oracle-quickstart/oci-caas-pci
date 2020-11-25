#!/bin/bash

RULES_JSON="`dirname $0`/oci-caas-waf-rules.json"

if [[ -z $1 ]]
then
  echo "Please pass the OCID of the WAAS Policy as an argument"
  echo "Example: `basename $0` ocid1.waaspolicy.oc1..eibcccntjufdvhgllcrhluukktilvdlrhetgvfcrdh"
  exit 255
else
  WAAS_OCID=$1
fi

oci waas protection-rule update --waas-policy-id $WAAS_OCID --protection-rules file://${RULES_JSON}

if [[ $? -ne 0 ]]
then
  echo 'Problem with updating rules. Please see error above for details.'
  exit 1
else
  echo "Successfully kicked off update. Please monitor the update through the OCI console or by tracking the work request ID above."
fi