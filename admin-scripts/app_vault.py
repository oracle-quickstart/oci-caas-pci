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


# This function creates a new vault in the given compartment using KMS Vault client and waits until the vault
# status is Active
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


# This function creates a new management key in the given vault using KMS Management client and waits until the key
# is Enabled
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
        print("Error with vault creation. Exiting.")
        sys.exit()


def create_secret(compartment_id, secret_content, secret_name, vault_id, key_id, config, tag_name):
    try:
        vaults_client = oci.vault.VaultsClient(config)
        vaults_client_composite = oci.vault.VaultsClientCompositeOperations(vaults_client)
        name = secret_name
        print("Creating a secret {}.".format(secret_name))

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
        print("Error with vault creation. Exiting.")
        sys.exit()


# Reads the compartment ID and the identity from the configuration file
def get_compartmentID_and_Ident(filename):
    # Open the file in read mode
    with open(filename, 'r') as file_object:
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
def write_VaultID_and_KeyID(vault_id, key_id, filename):
    vaultID = ""
    mgmtKey = ""
    with open(filename, 'r') as file_object:
        for line in file_object:
            if line.startswith("vault_id"):
                vaultID = line
            if line.startswith("mgmtkey"):
                mgmtKey = line
    file = open(filename, "rt")
    data = file.read()
    data = data.replace(vaultID, 'vault_id=' + vault_id + '\n')
    data = data.replace(mgmtKey, 'mgmtkey=' + key_id)
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
    config_filename = os.environ.get("HOME") + "/.oci-caas/oci-caas-pci.conf"
    if not os.path.exists(config_filename):
        raise Exception("Error with vault creation. Configuration file does not exist.")

    stripe_api_sk, stripe_api_pk, ecom_db_pw = getKeys(requiredLength)

    stripe_api_sk = text_to_base64(stripe_api_sk)
    stripe_api_pk = text_to_base64(stripe_api_pk)
    ecom_db_pw = text_to_base64(ecom_db_pw)

    compartment_ID, ident = get_compartmentID_and_Ident(config_filename)

    path1 = os.environ.get("HOME") + "/.oci/config"
    path2 = "/etc/oci/config"

    if os.path.exists(path1):
        configuration = from_file(file_location=path1)
    elif os.path.exists(path2):
        configuration = from_file(file_location=path2)
    else:
        raise Exception("Error with vault creation. Configuration file does not exist.")

    COMPARTMENT_ID = compartment_ID
    VAULT_NAME = ident
    KEY_NAME = "mgmt-key"

    vault = createVault(COMPARTMENT_ID, VAULT_NAME, configuration).data

    try:
        VAULT_ID = vault.id
    except:
        print("Unable to retrieve oci vault. Exiting due to errors.")

    print(" Created vault {} with id : {}".format(VAULT_NAME, VAULT_ID))
    try:
        service_mgmt_endpoint = vault.management_endpoint
    except:
        print("Unable to retrieve management endpoint. Exiting due to errors.")

    key = createKey(KEY_NAME, COMPARTMENT_ID, configuration, service_mgmt_endpoint).data

    try:
        KEY_ID = key.id
    except:
        print("Unable to retrieve vault management key. Exiting due to errors.")

    print(" Created key {} with id : {}".format(KEY_NAME, KEY_ID))

    print("Uploading Secrets to Vault...")
    secret_name1 = "stripe_api_sk"
    create_secret(COMPARTMENT_ID, stripe_api_sk, secret_name1, VAULT_ID, KEY_ID, configuration, ident + "-stripe-sk")
    secret_name2 = "stripe_api_pk"
    create_secret(COMPARTMENT_ID, stripe_api_pk, secret_name2, VAULT_ID, KEY_ID, configuration, ident + "-stripe-pk")
    secret_name3 = "ecom_db_pw"
    create_secret(COMPARTMENT_ID, ecom_db_pw, secret_name3, VAULT_ID, KEY_ID, configuration, ident + "-db-pw")
    print("Successfully Uploaded the secrets")

    write_VaultID_and_KeyID(VAULT_ID, KEY_ID, config_filename)
