#!/usr/bin/env python3
import sys
import oci
import os
import subprocess
from datetime import date
from oci.config import from_file


# Create the certificate in the WAF
def create_waas_certificate(compartment_id, cert_data, key_data, config, domain_name):
    try:

        waas_client = oci.waas.WaasClient(config)
        certificate_details = oci.waas.models.CreateCertificateDetails(
            compartment_id=compartment_id,
            certificate_data=cert_data,
            private_key_data=key_data,
            display_name=domain_name + "-cert-" + date.today)

        response = waas_client.create_certificate(create_certificate_details=certificate_details,
                                                  wait_for_states=[
                                                      oci.waas.models.Certificate.LIFECYCLE_STATE_ACTIVE])

        return response
    except:
        print("Error with Certificate Creation. Failed to create WAAS Certificate. Exiting.")
        sys.exit()


#  Update dns record in oci
def update_dns_domain_record(domain_name, text_domain, rdata, rtype, ttl, config):
    try:

        dns_client = oci.dns.DnsClient(config)
        record_details = oci.dns.models.RecordDetails(domain=domain_name,
                                                      rdata=rdata,
                                                      rtype=rtype,
                                                      ttl=ttl)
        domain_records_details = oci.dns.models.UpdateDomainRecordsDetails(items=record_details)

        response = dns_client.update_domain_records(zone_name_or_id=domain_name,
                                                    domain=text_domain,
                                                    update_domain_records_details=domain_records_details)

        return response
    except:
        print("Error with Certificate Creation. Failed to create WAAS Certificate. Exiting.")
        sys.exit()


# Gets the cert data and key data
def get_secret_data(path):
    secret_data = ""
    with open(path, "r") as file:
        for line in file:
            if line != "\n":
                secret_data = secret_data + line

    return secret_data


# Get validation records from registration command
def get_acme_validation_records(acme, domain_name):
    text_values = []
    response = subprocess.run(
        "ACME={}; domain={}; ${ACME}/acme.sh --issue  -d $domain --dns -d \*.$domain --yes-I-know-dns-manual-mode-enough-go-ahead-please".format(
            acme, domain_name), shell=True)
    for line in response:
        if "TXT value" in line:
            line = line.split(':')[1][2:-2]
            text_values.append(line)
    return text_values


# register
def register_or_renew_acme(acme, domain_name):
    response = subprocess.run(
        "ACME={}; domain={}; ${ACME}/acme.sh --issue  -d $domain --dns -d \*.$domain --yes-I-know-dns-manual-mode-enough-go-ahead-please --renew".format(
            acme, domain_name), shell=True)
    return response


def check_if_path_exists(path):
    if os.path.exists(path):
        return True


def write_to_conf(filename, certificate_ocid):
    try:
        file = open(filename, "a")
        file.write("frontend_ssl_certificate_id=" + certificate_ocid)
        file.close()
    except:
        print("Error while uploading the certificate ocid to oci-caas-pci.conf file")


if __name__ == "__main__":
    domain, compartment_ocid = "", ""
    usage = "Usage: `python3 ssl_certificate.py <domain> <COMPARTMENT_OCID>" + \
            "- [Required] Domain should be a valid domain already configured in OCI DNS" + \
            "- [Required] OCID should be the OCID of the compartment from where the service will run"

    # Check if arguments are passed to the function or not
    if len(sys.argv) > 2:
        print(usage)
        sys.exit()
    else:
        domain = str((sys.argv[0]))
        compartment_ocid = str((sys.argv[1]))

    ACME = os.environ.get("HOME") + "/.acme.sh"

    oci_caas_pci_config = os.environ.get("HOME") + "/.oci-caas/oci-caas-pci.conf"

    # Checks if oci-caas-pci.conf exists
    if not check_if_path_exists(oci_caas_pci_config):
        raise FileNotFoundError(
            "{} file does not exist. Please ensure you have run the Getting Started process.".format(
                oci_caas_pci_config))

    # Checks if acme.sh exists
    if not check_if_path_exists(ACME + "/acme.sh"):
        raise FileNotFoundError("Unable to find default acme.sh installation. Please install acme.sh and try again.")

    # This is the configuration file with the tenancy_id and fingerprint
    path1 = os.environ.get("HOME") + "/.oci/config"
    path2 = "/etc/oci/config"

    if check_if_path_exists(path1):
        local_config = from_file(file_location=path1)
    elif check_if_path_exists(path2):
        local_config = from_file(file_location=path2)
    else:
        raise FileNotFoundError("Error with vault creation. {} file or {} file does not exist.".format(path1, path2))

    # Text domain for acme
    txt_domain = "_acme-challenge." + domain

    # Check is compartment id and domain name exists
    if compartment_ocid == "" or domain == "":
        print(usage)
        sys.exit()

    acme_txt_value = get_acme_validation_records(ACME, domain)

    # Updating dns_domain_record with zone_name_or_id, domain, rdata, rtype and ttl
    update_dns_domain_record(domain, txt_domain, acme_txt_value[0], "TXT", 30, local_config)
    update_dns_domain_record(domain, txt_domain, acme_txt_value[1], "TXT", 30, local_config)

    # Register
    register_or_renew_acme(ACME, domain)

    # Gets the certificate data
    cert_data_path = ACME + "/" + domain + "/" + domain + ".key"
    certificate_data = get_secret_data(cert_data_path)

    # Gets the key data
    key_data_path = ACME + "/" + domain + "/" + domain + ".key"
    secret_key_data = get_secret_data(key_data_path)

    certificate = create_waas_certificate(compartment_ocid, certificate_data, secret_key_data, local_config, domain)

    # Gets the certificate OCID
    cert_ocid = certificate.data.key_id
    print("Certificate OCID: {}".format(cert_ocid))
    # Writes the certificate OCID to oci-caas-pci.conf file
    write_to_conf(oci_caas_pci_config, cert_ocid)

