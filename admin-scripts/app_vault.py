#!/usr/bin/env python3
import sys
import base64
import oci
import os
from oci.config import from_file


# This function gets the stripe keys and database password from the user
def getKeys(passwordLength):
    print("We will capture three values for this application environment:")
    print("1) The Stripe secret key")
    print("2) The Stripe publishable key")
    print("3) The database password to be set for the ECOM user")
    print("\nA password must contain at least {} characters, a number, a special character, a "
          "lowercase letter and a uppercase letter!! \n".format(passwordLength))
    print("If you are not ready to provide this information, you may cancel this script now, "
          "or hit <ENTER/RETURN> to continue.")
    print("Note: These values are *not* logged.")
    print("")
    temp = input("<ENTER> or Quit (q)")
    if temp == 'q':
        sys.exit()
    secret_key = input("Please enter the Stripe secret key: ")
    public_key = input("Please enter the Stripe public key: ")
    database_pwd = input("Please enter the ECOM user password: ")

    while validatePassword(database_pwd, passwordLength) is False:
        database_pwd = input("Please re-enter the ECOM user password: ")

    return secret_key, public_key, database_pwd


# This function validates the database password meets all the requirements for a password
def validatePassword(password, passwordLength):
    special = "@#$%^&*()_-+={}[]\/<>,.;?':| "
    caps, lower, num, specialChar, length = False, False, False, False, False
    for i in password:
        if i.isupper():
            caps = True
        elif i.islower():
            lower = True
        elif i.isdigit():
            num = True
        elif i in special:
            specialChar = True
    if len(password) > passwordLength:
        length = True
    if not caps:
        print("....Required at least a uppercase letter (A–Z)!")
    if not lower:
        print("....Required at least a lowercase letter (a–z)!")
    if not specialChar:
        print("....Required at least a special character. List of special characters include "
              "{}(space)".format(special))
    if not num:
        print("....Required at least a number (0–9)!")
    if not length:
        print("....Required at least {} characters!".format(passwordLength))
    isValid = False
    if caps and lower and num and specialChar and length:
        isValid = True

    return isValid


# This function returns vault id and service endpoint if the vault exists in .oci-caas/oci-caas-pci.conf and in OCI Console
# else returns None
def get_vault(config, oci_config):
    try:
        vaultClient = oci.key_management.KmsVaultClient(config)
        print("Checking to see if Vault already exists...")

        with open(oci_config, "r") as file_object:
            for line in file_object:
                if line.startswith("vault_id="):
                    existingVaultID = line.split('=')[1]
                    # Checking if the vault id in the .oci-caas/oci-caas-pci.conf file
                    if existingVaultID != "\n":
                        existingVaultID = existingVaultID[0:-1]
                        print("Vault ID exists in .oci-caas/oci-caas-pci.conf")
                        try:
                            response = vaultClient.get_vault(existingVaultID)
                            # Checking if the vault id in the config file exists in console
                            print("Vault already exists in the compartment. Details for Vault:{}".format(response.data))
                            data = response.data
                            mgmt_endpoint = data.management_endpoint
                            return existingVaultID, mgmt_endpoint
                        except:
                            print("Error in Vault Creation. Vault ID {} in .oci-caas/oci-caas-pci.conf does not exist.".format(
                                    existingVaultID))
                            sys.exit()
                    else:
                        return None, None
    except:
        print("Error retrieving the vault. Exiting")
        sys.exit()


# This function existing mgmt key id mgmt key exists else empty string
def get_mgmt_key(config, oci_config, mgmt_endpoint):
    try:
        mgmtKeyClient = oci.key_management.KmsManagementClient(config, mgmt_endpoint)
        print("Checking to see if Management Key exists...")

        with open(oci_config, "r") as file_object:
            for line in file_object:
                if line.startswith("mgmtkey="):
                    existingMgmtKeyID = line.split('=')[1]
                    if existingMgmtKeyID != "":
                        print("Management Key exists in .oci-caas/oci-caas-pci.conf")

                        existingMgmtKeyID = existingMgmtKeyID[0:-1]
                        try:
                            response = mgmtKeyClient.get_key(existingMgmtKeyID)
                            print(
                                "Management Key exists in the Vault. Details for Key:{}".format(response.data))
                            return existingMgmtKeyID
                        except:
                            print(
                                "Error creating management key. Management key {} in .oci-caas/oci-caas-pci.conf does not exist".format(
                                    existingMgmtKeyID))
                            sys.exit()

                    else:
                        return ""
    except:
        print("Unable to create vault management key. Exiting")
        sys.exit()


def check_or_create_secret(config, compartment_id, vault_id, key_id, secret_name, secret_value, tag_name):
    try:
        secretClient = oci.vault.VaultsClient(config)
        isSecret = False
        response = secretClient.list_secrets(compartment_id=compartment_id, vault_id=vault_id)
        for i in range(len(response.data)):
            if response.data[i].secret_name == secret_name:
                print("{} already exists. {} OCID : {} ".format(secret_name, secret_name, response.data[i].id))
                isSecret = True

        if not isSecret:
            print("Uploading {} to Vault...".format(secret_name))
            create_secret(compartment_id, secret_value, secret_name, vault_id, key_id, config, tag_name)
            print("Successfully Uploaded the {} ".format(secret_name))
    except:
        print("Error while creating or retrieving the secret {} in the vault".format(secret_name))
        sys.exit()


# This function creates a new vault in the given compartment using KMS Vault client and waits until vault status is Active
def createVault(compartment_id, ident, config):
    try:
        key_management_client = oci.key_management.KmsVaultClient(config)
        sac_composite = oci.key_management.KmsVaultClientCompositeOperations(key_management_client)
        print(" Creating vault oci-caas-{} in {} compartment.".format(ident,
                                                                      compartment_id))

        vault_details = oci.key_management.models.CreateVaultDetails(
            compartment_id=compartment_id,
            vault_type="DEFAULT",
            display_name="oci-caas-" + ident,
            freeform_tags={"oci-caas-" + ident + "-vault": ""})

        print("Vault details {}.".format(vault_details.vault_type))
        print("Waiting for vault to be created - This could take a few minutes.")

        # Create vault and wait for the vault to become Active
        response = sac_composite.create_vault_and_wait_for_state(
            vault_details,
            wait_for_states=[oci.key_management.models.Vault.LIFECYCLE_STATE_ACTIVE])
        return response
    except:
        print("Error with vault creation. Exiting.")
        sys.exit()


# This function creates a new management key in the given vault using KMS Management client and waits until key is Enabled
def createKey(key_name, compartment_id, config, service_endpoint):
    try:
        key_management_client = oci.key_management.KmsManagementClient(config, service_endpoint)
        key_mgmt_composite = oci.key_management.KmsManagementClientCompositeOperations(key_management_client)
        print(" Creating key {} in compartment {}.".format(key_name, compartment_id))

        key_shape = oci.key_management.models.KeyShape(algorithm="AES", length=32)
        key_details = oci.key_management.models.CreateKeyDetails(
            compartment_id=compartment_id,
            display_name=key_name,
            key_shape=key_shape)

        # Create management key and wait for the key to be Enabled
        response = key_mgmt_composite.create_key_and_wait_for_state(key_details,
                                                                    wait_for_states=[
                                                                        oci.key_management.models.Key.LIFECYCLE_STATE_ENABLED])
        return response
    except:
        print("Error with Management Key creation. Exiting.")
        sys.exit()


# This function creates a new secret in the given vault using Vault Client and waits until key is Active
def create_secret(compartment_id, secret_content, secret_name, vault_id, key_id, config, tag_name):
    try:

        vaults_client = oci.vault.VaultsClient(config)
        vaults_client_composite = oci.vault.VaultsClientCompositeOperations(vaults_client)

        # Create secret_content_details that needs to be passed when creating secret.
        secret_description = "Secret"
        secret_content_details = oci.vault.models.Base64SecretContentDetails(
            content_type=oci.vault.models.SecretContentDetails.CONTENT_TYPE_BASE64,
            name="SecretContent",
            stage="CURRENT",
            content=secret_content)
        secrets_details = oci.vault.models.CreateSecretDetails(compartment_id=compartment_id,
                                                               description=secret_description,
                                                               secret_content=secret_content_details,
                                                               secret_name=secret_name,
                                                               vault_id=vault_id,
                                                               key_id=key_id,
                                                               freeform_tags={tag_name: ""})
        # Create secret and wait for the secret to become active
        response = vaults_client_composite.create_secret_and_wait_for_state(create_secret_details=secrets_details,
                                                                            wait_for_states=[
                                                                                oci.vault.models.Secret.LIFECYCLE_STATE_ACTIVE])
        return response
    except:
        print("Error with Secret Creation. Failed to create {}. Exiting.".format(secret_name))
        sys.exit()


def upload_vault(compartment_id, ident, config):
    vault_id = ""
    mgmt_endpoint = ""
    vault = createVault(compartment_id, ident, config).data

    try:
        vault_id = vault.id
    except:
        print("Unable to retrieve oci vault. Exiting due to errors.")
    try:
        mgmt_endpoint = vault.management_endpoint
    except:
        print("Unable to retrieve management endpoint. Exiting due to errors.")

    write_config_file(oci_caas_pci_config, "vault_id=", vault_id)

    print(" Created vault {} with id : {}".format(identity, vault_id))
    return vault_id, mgmt_endpoint


def upload_key(key_name, compartment_id, config, mgmt_endpoint, oci_config):
    print("Creating Management Key...")
    key_id = ""
    mgmt_key = createKey(key_name, compartment_id, config, mgmt_endpoint).data
    try:
        key_id = mgmt_key.id
    except:
        print("Unable to retrieve vault management key. Exiting due to errors.")

    write_config_file(oci_config, "mgmtkey=", key_id)

    print(" Created key {} with id : {}".format(key_name, key_id))

    return key_id


def upload_secrets(compartment_id, secret_name, secret_value, vault_id, key_id, config, tag_name):
    try:
        print("Uploading {} to Vault...".format(secret_name))
        create_secret(compartment_id, secret_value, secret_name, vault_id, key_id, config, tag_name)
        print("Successfully Uploaded the {} ".format(secret_name))
    except:
        print("Error while uploading the secret")
        sys.exit()


# Reads the compartment ID and the identity from the configuration file
def get_compartmentID_and_Ident(filename):
    # Open the file in read mode
    with open(filename, "r") as file_object:
        i = 0
        for line in file_object:

            if i == 0:
                compartment_ocid = line
                compartment_ocid = compartment_ocid.split("=", 1)
                compartment_ocid = compartment_ocid[1].split("\n", 1)
            elif i == 2:
                ident = line
                ident = ident.split("=", 1)
                ident = ident[1].split("\n", 1)

            i += 1

    return compartment_ocid[0], ident[0]


# Writes the vault ID and the management key ID to the configuration file
def write_config_file(filename, config_key, config_value):
    file = open(filename, "rt")
    data = file.read()
    data = data.replace(config_key, config_key + config_value)
    file.close()
    file = open(filename, "wt")
    file.write(data)
    file.close()


def text_to_base64(secret_str):
    secret_str_bytes = base64.b64encode(secret_str.encode("utf-8"))
    secret_str = str(secret_str_bytes, "utf-8")
    return secret_str


if __name__ == "__main__":
    requiredLength = 12

    # This is the configuration file on oci cloud shell where we write the vault_id and mgmt_id
    oci_caas_pci_config = os.environ.get("HOME") + "/.oci-caas/oci-caas-pci.conf"
    if not os.path.exists(oci_caas_pci_config):
        raise Exception("Error with vault creation. {} file does not exist.".format(oci_caas_pci_config))

    # This is the configuration file with the tenancy_id and fingerprint
    path1 = os.environ.get("HOME") + "/.oci/config"
    path2 = "/etc/oci/config"

    if os.path.exists(path1):
        local_config = from_file(file_location=path1)
    elif os.path.exists(path2):
        local_config = from_file(file_location=path2)
    else:
        raise Exception("Error with vault creation. {} file or {} file does not exist.".format(path1, path2))

    # Getting all the secrets
    stripe_api_sk, stripe_api_pk, ecom_db_pw = getKeys(requiredLength)

    # Converting the secrets from text to base64
    stripe_api_sk = text_to_base64(stripe_api_sk)
    stripe_api_pk = text_to_base64(stripe_api_pk)
    ecom_db_pw = text_to_base64(ecom_db_pw)

    # Getting the compartment ID and ident
    COMPARTMENT_ID, identity = get_compartmentID_and_Ident(oci_caas_pci_config)

    # Checking if the Vault exists in configuration file or OCI console
    VAULT_ID, service_mgmt_endpoint = get_vault(local_config, oci_caas_pci_config)

    # If no vault exists creating a new Vault
    if VAULT_ID is None or service_mgmt_endpoint is None:
        VAULT_ID, service_mgmt_endpoint = upload_vault(COMPARTMENT_ID, identity, local_config)

    # Checking if the management key exists in configuration file or OCI console
    KEY_ID = get_mgmt_key(local_config, oci_caas_pci_config, service_mgmt_endpoint)
    # If no management key exists creating a new management key
    if KEY_ID == "":
        KEY_ID = upload_key("mgmt-key", COMPARTMENT_ID, local_config, service_mgmt_endpoint, oci_caas_pci_config)

    # List of secrets
    secret_list = {"stripe_api_sk": [stripe_api_sk, identity + "-stripe-sk"],
                   "stripe_api_pk": [stripe_api_pk, identity + "-stripe-pk"],
                   "ecom_db_pw": [ecom_db_pw, identity + "-db-pw"]}

    # Checking if the secrets exists in OCI console if not creating a new secrets
    for key in secret_list:
        check_or_create_secret(local_config, COMPARTMENT_ID, VAULT_ID, KEY_ID, key, secret_list[key][0],
                               secret_list[key][1])
