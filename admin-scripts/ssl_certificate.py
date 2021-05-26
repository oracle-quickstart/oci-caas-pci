#!/usr/bin/env python3
import sys
import oci
import os
import subprocess
from datetime import date
from oci.config import from_file


# Create the certificate in the WAF
def create_waas_certificate(compartment_id, cert_data, key_data, config, display_name):
    try:
        waas_client = oci.waas.WaasClient(config)
        cert_composite = oci.waas.WaasClientCompositeOperations(waas_client)
        certificate_details = oci.waas.models.CreateCertificateDetails(
            compartment_id=compartment_id,
            certificate_data=cert_data,
            private_key_data=key_data,
            display_name=display_name)

        response = cert_composite.create_certificate_and_wait_for_state(create_certificate_details=certificate_details,
                                                                        wait_for_states=[
                                                                            oci.waas.models.Certificate.LIFECYCLE_STATE_ACTIVE])
        return response
    except:
        print("Error with Certificate Creation. Failed to create WAAS Certificate. Exiting.")
        sys.exit()


#  Retrieves the DNS Domain Record details
def get_record_details(text_domain, rdata_list, rtype, ttl):
    try:
        record_details = oci.dns.models.RecordDetails(domain=text_domain,
                                                      rdata=rdata_list,
                                                      rtype=rtype,
                                                      ttl=ttl)

        return record_details
    except:
        print("Error with retrieving the DNS Domain Record details. Exiting.")
        sys.exit()


#  Update DNS Domain Record in OCI
def update_dns_domain_record(record_details_list, domain_name, text_domain, config):
    try:
        dns_client = oci.dns.DnsClient(config)
        print(record_details_list)

        domain_records_details = oci.dns.models.UpdateDomainRecordsDetails(items=record_details_list)

        response = dns_client.update_domain_records(zone_name_or_id=domain_name,
                                                    domain=text_domain,
                                                    update_domain_records_details=domain_records_details)
        return response
    except:
        print("Error with updating the DND Domain Record. Exiting.")
        sys.exit()


# Gets the cert data and key data
def get_secret_data(path):
    secret_data = ""
    with open(path, "r") as file:
        for line in file:
            if line != "\n":
                secret_data = secret_data + line

    return str(secret_data)


# Get validation records from registration command
def get_acme_validation_records(acme, domain_name):
    try:
        text_values = []
        response = subprocess.getoutput(
            "acme_cmd={}; domain={}; $acme_cmd/acme.sh --issue  -d $domain --dns -d \*.$domain --yes-I-know-dns-manual-mode-enough-go-ahead-please".format(
                acme, domain_name))
        print(response)
        for line in response.splitlines():
            if "TXT value" in line:
                line = line.split("TXT value:")[1][2:-1]
                text_values.append(line)
        if not text_values:
            print("Unable to register domain with acme.sh at this time. See message above for details.")
            sys.exit()
        return text_values
    except:
        print("Error while retrieving validation records for ACME. Exiting")
        sys.exit()


# register
def register_or_renew_acme(acme, domain_name):
    try:
        response = subprocess.run(
            "acme_cmd={}; domain={}; $acme_cmd/acme.sh --issue  -d $domain --dns -d \*.$domain --yes-I-know-dns-manual-mode-enough-go-ahead-please --renew".format(
                acme, domain_name), shell=True)

        print(response)
        return response
    except:
        print("Error while registering or renewing ACME. Exiting")
        sys.exit()


def write_to_conf(filename, certificate_ocid):
    try:
        file = open(filename, "a")
        file.write("frontend_ssl_certificate_id=" + certificate_ocid + "\n")
        file.close()
    except:
        print("Error while uploading the certificate ocid to oci-caas-pci.conf file")
        sys.exit()


if __name__ == "__main__":
    domain, compartment_ocid = "", ""
    usage = "Usage: `python3 ssl_certificate.py <DOMAIN> <COMPARTMENT_OCID> \n" + \
            "- [Required] Domain should be a valid domain already configured in OCI DNS \n" + \
            "- [Required] OCID should be the OCID of the compartment from where the service will run \n"

    # Check if arguments are passed to the function or not
    if len(sys.argv) == 3:
        domain = str((sys.argv[1]))
        compartment_ocid = str((sys.argv[2]))
    else:
        print(usage)
        sys.exit()

    ACME = os.environ.get("HOME") + "/.acme.sh"
    oci_caas_pci_config = os.environ.get("HOME") + "/.oci-caas/oci-caas-pci.conf"

    # This is the configuration file with the tenancy_id and fingerprint
    path1 = os.environ.get("HOME") + "/.oci/config"
    path2 = "/etc/oci/config"

    # Text domain for acme
    txt_domain = "_acme-challenge." + domain

    # Checks if oci-caas-pci.conf exists
    if not os.path.exists(oci_caas_pci_config):
        raise FileNotFoundError(
            "{} file does not exist. Please ensure you have run the Getting Started process.".format(
                oci_caas_pci_config))

    # Checks if acme.sh exists
    if not os.path.exists(ACME + "/acme.sh"):
        raise FileNotFoundError("Unable to find default acme.sh installation. Please install acme.sh and try again.")

    if os.path.exists(path1):
        local_config = from_file(file_location=path1)
    elif os.path.exists(path2):
        local_config = from_file(file_location=path2)
    else:
        raise FileNotFoundError("Error with vault creation. {} file or {} file does not exist.".format(path1, path2))

    # Check if compartment id and domain name exists
    if not compartment_ocid or not domain:
        print(usage)
        sys.exit()

    # Gets the acme validation records
    acme_txt_value = get_acme_validation_records(ACME, domain)

    # Gets the acme TXT Values for RDATA
    record_list = [get_record_details(txt_domain, acme_txt_value[0], "TXT", 30),
                   get_record_details(txt_domain, acme_txt_value[1], "TXT", 30)]

    # Updating dns_domain_record with zone_name_or_id, domain, rdata values, rtype and ttl
    update_dns_domain_record(record_list, domain, txt_domain, local_config)

    # Register
    register_or_renew_acme(ACME, domain)

    # Gets the certificate data
    cert_data_path = ACME + "/" + domain + "/fullchain.cer"
    certificate_data = get_secret_data(cert_data_path)
    print(certificate_data)

    # Gets the key data
    key_data_path = ACME + "/" + domain + "/" + domain + ".key"
    secret_key_data = get_secret_data(key_data_path)
    print(secret_key_data)

    today = str(date.today())
    cert_display_name = str(domain + "-cert-" + today)

    certificate = create_waas_certificate(compartment_ocid, certificate_data, secret_key_data, local_config,
                                          cert_display_name)

    # Gets the certificate OCID
    cert_ocid = certificate.data.id
    print("Successfully created WAAS Certificate with OCID: {}".format(cert_ocid))

    # Writes the certificate OCID to oci-caas-pci.conf file
    write_to_conf(oci_caas_pci_config, cert_ocid)
