#!/bin/sh
. caas-functions.sh

# domain="top-level-domain.com"
admin_compartment_ocid=""

txt_domain="_acme-challenge.${domain}"

umask 077
tmp="/tmp/dns_reg.$$/"
mkdir ${tmp}
 
# Get validation records from registration command
text_values=`./acme.sh --issue  -d $domain --dns -d \*.$domain --yes-I-know-dns-manual-mode-enough-go-ahead-please 2> /dev/null | grep "TXT value: "  | awk -F\' '{printf ("%s "), $2}'`
 
echo $text_values
 
# Build part of a json structure for DNS update
for value in $text_values
do
  echo $value
  echo { \"domain\": \"$txt_domain\", \"rtype\": \"TXT\", \"ttl\": 30, \"rdata\": \"$value\" } >> ${tmp}/records.txt
done
 
# turn the list of records into an array
jq -s . ${tmp}/records.txt > ${tmp}/dns_items.json
 
# dns updates
oci dns record domain update --zone-name-or-id $domain --domain $txt_domain --items file://${tmp}/dns_items.json --force
 
# register
./acme.sh  --issue  -d $domain --dns -d \*.$domain --yes-I-know-dns-manual-mode-enough-go-ahead-please --renew
 
# Cert chain and key to be stored in a certificate object for the WAF
certdata=`grep -v '^$' ${HOME}/.acme.sh/${domain}/fullchain.cer`
keydata=`cat ${HOME}/.acme.sh/${domain}/${domain}.key`
 
# Create the certificate in the WAF
oci waas certificate create --compartment-id $admin_compartment_ocid --certificate-data "$certdata" --private-key-data "$keydata" --display-name "${domain}-cert"