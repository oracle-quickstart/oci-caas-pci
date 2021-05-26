#!/bin/bash

ACME="${HOME}/.acme.sh"
conf_file="${HOME}/.oci-caas/oci-caas-pci.conf"
. `dirname $0`/caas-functions.sh

if [[ ! -f $conf_file ]]
then
  echo "No configuration file found. Please ensure you have run the Getting Started process."
  exit 1
else
  . $conf_file
fi

if [[ ! -f ${ACME}/acme.sh ]]
then
  echo "Unable to find default acme.sh installation. Please install acme.sh and try again."
  exit 2
fi

if [[ -n $compartment_id ]]
then
  compartment_ocid=$compartment_id
fi

usage="Usage: `basename $0` -d <domain> [-o <OCID>]
- Domain should be a valid domain already configured in OCI DNS
- OCID should be the OCID of the compartment from where the service will run

Note: If no OCID is provied, the OCID of the compartment created in Getting Started will be used."

while getopts ":d:o:h" opt; do
  case ${opt} in
    d) domain=$OPTARG ;;
    o) compartment_ocid=$OPTARG ;;
    :) echo "Invalid option: $OPTARG requires an argument" 1>&2 ;;
    h) echo "$usage" ;;
    \?) echo "Invalid option: $OPTARG" 1>&2 ;;
  esac
done
shift $((OPTIND -1))

if [[ -z $domain || -z $compartment_ocid ]]
then
  echo 'Missing required values:'
  echo "$usage"
  exit 3
fi

txt_domain="_acme-challenge.${domain}"

umask 077
tmp="/tmp/dns_reg.$$/"
mkdir ${tmp}
 
# Get validation records from registration command
text_values=`${ACME}/acme.sh --issue  -d $domain --dns -d \*.$domain --yes-I-know-dns-manual-mode-enough-go-ahead-please | tee ${tmp}/cert-issue.out 2> /dev/null | grep "TXT value: "  | awk -F\' '{printf ("%s "), $2}'`
 
if [[ -z $text_values ]]
then
  echo "Unable to to determine registration record values."
  echo "Output from acme.sh:"
  cat ${tmp}/cert-issue.out
  exit 255
fi

# Build part of a json structure for DNS update
for value in $text_values
do
  echo { \"domain\": \"$txt_domain\", \"rtype\": \"TXT\", \"ttl\": 30, \"rdata\": \"$value\" } >> ${tmp}/records.txt
done

# turn the list of records into an array
jq -s . ${tmp}/records.txt > ${tmp}/dns_items.json
 
# dns updates
oci dns record domain update --zone-name-or-id $domain --domain $txt_domain --items file://${tmp}/dns_items.json --force
 
# register
${ACME}/acme.sh --issue  -d $domain --dns -d \*.$domain --yes-I-know-dns-manual-mode-enough-go-ahead-please --renew
 
# Cert chain and key to be stored in a certificate object for the WAF
certdata=`grep -v '^$' ${ACME}/${domain}/fullchain.cer`
keydata=`cat ${ACME}/${domain}/${domain}.key`
 
# Create the certificate in the WAF
display_name="${domain}-cert-`date '+%Y%m%d'`"
oci waas certificate create --compartment-id $compartment_ocid --certificate-data "$certdata" --private-key-data "$keydata" --display-name "$display_name" | tee ${tmp}/oci_cert_create.out

cert_ocid=`grep '"id"' ${tmp}/oci_cert_create.out | awk -F\" '{print $4}'`
if [[ -n $cert_ocid ]]
then
  echo "Certificate OCID: $cert_ocid"
  update_configuration $CONF frontend_ssl_certificate_id $cert_ocid
  exit 0
else
  echo "Unable to determine Certificate OCID. Please review ${tmp}/oci_cert_create.out for more details."
  exit 255
fi