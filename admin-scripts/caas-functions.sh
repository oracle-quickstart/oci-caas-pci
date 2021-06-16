function update_configuration() {
  conf="$1"
  key="$2"
  value="$3"

  sed "s/^\(${key}\s*=\s*\).*\$/\1${value}/" -i $conf
}

function get_response() {
  question="$1"
  unset response
  until [[ -n $response ]]
  do
    read -e -p "$question" response
  done
  echo $response
}

# Initialize configuration file
function initialize_configuration() {
  conf="$1"
  values="compartment_id tenancy_ocid ident caas_bucket os_namespace vault_id mgmtkey"

  for value in $values
  do
    echo "${value}=" >> $conf
  done
}

function get_root_compartment_ocid() {
  tenancy=`oci iam compartment list --raw-output --query 'data[0]."compartment-id"'`
  if [[ $? -eq "0" ]]
  then
    echo $tenancy
    return 0
  else
    echo "Unable to obtain tenancy OCID." 1>&2
    return 1
  fi
}

function get_bucket_namespace() {
  compartment_id="$1"
  os_namespace=`oci os ns get --compartment-id $compartment_id --raw-output --query 'data'`
  echo $os_namespace
}

# Create bucket
function create_bucket() {
  bucket_create_log="/tmp/oci-caas-$$-bucket-create.log"
  compartment_id=$1
  bucket_name=$2

  oci os bucket create --compartment-id $compartment_id --name $bucket_name > $bucket_create_log 2>&1
  if [[ $? -eq "0" ]]
  then
    return 0
  else
    echo "Unable to create new bucket ${bucket_name} - Please see $bucket_create_log for more info." 1>&2
    return 1
  fi
}

# Create compartment
function create_compartment() {
  compartment_create_log="/tmp/oci-caas-$$-compartment-create.log"

  name="$1"
  parent="$2"
  description="$3"

  oci iam compartment create --compartment-id $parent --name $name --description "$description" > $compartment_create_log 2>&1
  if [[ $? -eq "0" ]]
  then
    compartment_id=`jq '.data["id"]' $compartment_create_log | tr -d \"`
    echo $compartment_id
    return 0
  else
    echo "Unable to create new compartment. Please see $compartment_create_log for more info." 1>&2
    return 1
  fi
}

function cache_cookbooks() {
  cache_cookbooks_log="/tmp/oci-caas-$$-cache_cookbooks.log"
  namespace="$1"
  bucket_name="$2"
  export CINC_WORKSTATION="$HOME/opt/cinc-workstation"
  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$CINC_WORKSTATION/embedded/lib:embedded/lib/ruby/2.7.0"
  export SSL_CERT_FILE=${CINC_WORKSTATION}/embedded/ssl/certs/cacert.pem
  export CHEF_FIPS=""
  berks="${CINC_WORKSTATION}/embedded/bin/ruby -I${CINC_WORKSTATION}/embedded/lib/ruby/2.7.0 -I${CINC_WORKSTATION}/embedded/lib/ruby/2.7.0/x86_64-linux ${CINC_WORKSTATION}/bin/berks"

  cookbook_repos=(
    "https://github.com/oracle-quickstart/oci-caas-bastion.git"
    "https://github.com/oracle-quickstart/oci-caas-pci-tomcat.git"
    "https://github.com/oracle-quickstart/oci-caas-base.git"
    "https://github.com/oracle-quickstart/oci-caas-wazuh-server.git"
  )
  
  cache_dir="/tmp/caas-cache.$$"
  mkdir ${cache_dir}
  cd $cache_dir

  for repo in ${cookbook_repos[@]}
  do
    git clone $repo
  done

  for cookbook in *
  do
    cd $cookbook
    $berks package ../${cookbook}.tar.gz
    cd ..
  done

  echo "Uploading required cookbooks to $bucket_name bucket"
  for file in *.tar.gz
  do
    oci os object put -ns $namespace -bn $bucket_name --file $file --name $file --force >> $cache_cookbooks_log
    if [[ $? -ne 0 ]]
    then
      echo "Error uploading cookbook to bucket. Please see $cache_cookbooks_log for more information." 1>&2
      return 1
    fi
  done
  rm -rf ${cache_dir}
}

function validate_url(){
  is_valid_url="false"
  if [[ `wget -S --spider $1  2>&1 | grep 'HTTP/1.1 200 OK'` ]]
  then
    is_valid_url="true"
  fi
}

function download_cache_packages() {
  url_list=("http://downloads.cinc.sh/files/stable/cinc/16.9.29/el/7/cinc-16.9.29-1.el7.x86_64.rpm"
            "https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.60/bin/apache-tomcat-8.5.60.tar.gz"
            "https://github.com/oracle-quickstart/oci-caas-pci-ecommerce/releases/download/1.1.0/pci-ecommerce-1.2.0.war")

  cache_packages_log="/tmp/oci-caas-$$-cache_packages.log"
  cache_dir="/tmp/caas-cache.$$"
  mkdir $cache_dir
  cd $cache_dir

  for i in "${url_list[@]}"
  do
    validate_url "$i"
    wget "$i" >> $cache_packages_log 2>&1
    if [[ $is_valid_url != "true" ]]
    then
      echo "Error : $i does not exist. Please see $cache_packages_log for more information."
    fi
  done
}

function upload_cache_packages() {
  echo "Uploading required objects to $bucket_name bucket"
  cache_dir="/tmp/caas-cache.$$"
  cd $cache_dir
  namespace="$1"
  bucket_name="$2"
  for file in *
  do
    if [ -s  $file ]
    then
      oci os object put -ns $namespace -bn $bucket_name --file $file --name $file --force >> $cache_packages_log
      if [[ $? -ne 0 ]]
      then
        echo "Error uploading packages to bucket. Please see $cache_packages_log for more information." 1>&2
        return 1
      fi
    else
      echo "Error uploading packages to bucket. Package does not exist or is empty"
      return 1
    fi
  done
  rm -rf ${cache_dir}
}

function create_vault() {
  [[ $# -ne 2 ]] && echo "Incorrect numer of arguments passed to function." && return 255
  vault_create_log="/tmp/oci-caas-$$-vault-create.log"
  compartment_id="$1"
  display_name="$2"

  oci kms management vault create --compartment-id $compartment_id --display-name $display_name --vault-type DEFAULT --freeform-tags "{\"${display_name}-vault\": \"\"}" > $vault_create_log 2>&1
  if [[ $? -eq "0" ]]
  then
    return 0
  else
    echo "Unable to create new vault ${display_name} - Please see $vault_create_log for more info." 1>&2
    return 1
  fi
}

function get_vault_id() {
  [[ $# -ne 2 ]] && echo "Incorrect numer of arguments passed to function." && return 255
  compartment_id=$1
  display_name=$2
  vault_id=`oci search resource structured-search --query-text "query vault resources where (freeformTags.key = '${display_name}-vault' && compartmentId = '$compartment_id' && lifecycleState = 'CREATED') " | grep identifier | awk -F\" '{print $4}'`
  echo $vault_id
}

function get_vault_mgmt() {
  [[ $# -ne 1 ]] && echo "Incorrect numer of arguments passed to function." && return 255
  vault_id="$1"
  mgmt=`oci kms management vault get --vault-id $vault_id | grep management | awk -F\" '{print $4}'` 
  echo $mgmt
}

function get_vault_mgmt_key() {
  [[ $# -ne 2 ]] && echo "Incorrect numer of arguments passed to function." && return 255
  compartment_id=$1
  mgmt=$2

  # Ideally we filter by lifecycle-state: --query 'data[?"lifecycle-state" == ENABLED]."id"
  mgmtkey=`oci kms management key list --compartment-id $compartment_id --endpoint $mgmt 2> /dev/null | grep '"id":' | awk -F\" '{print $4}'`
  echo $mgmtkey
}

function create_kms_mgmt_key() {
  [[ $# -ne 2 ]] && echo "Incorrect numer of arguments passed to function." && return 255
  mgmt_key_create_log="/tmp/oci-caas-$$-mgmt-key-create.log"

  compartment_id=$1
  mgmt=$2

  oci kms management key create --compartment-id $compartment_id --display-name mgmt-key --key-shape '{"algorithm":"AES","length":"32"}' --endpoint $mgmt

  if [[ $? -eq "0" ]]
  then
    return 0
  else
    echo "Unable to create new vault mgmt key ${display_name} - Please see $mgmt_key_create_log for more info." 1>&2
    return 1
  fi
}

function populate_vault() {
  [[ $# -ne 7 ]] && echo "Incorrect numer of arguments passed to function." && return 255
  compartment_id=$1
  SK_BASE64=`echo $2 | base64 -w 0`
  PK_BASE64=`echo $3 | base64 -w 0`
  DBPW_BASE64=`echo $4 | base64 -w 0`
  vault_id=$5
  mgmtkey=$6
  ident=$7

  oci vault secret create-base64 --compartment-id $compartment_id --secret-name stripe_api_sk --vault-id $vault_id --description stripe_api_sk --key-id $mgmtkey --secret-content-content $SK_BASE64 --secret-content-name sk --secret-content-stage CURRENT --freeform-tags "{\"${ident}-stripe-sk\": \"\"}"
  oci vault secret create-base64 --compartment-id $compartment_id --secret-name stripe_api_pk --vault-id $vault_id --description stripe_api_sk --key-id $mgmtkey --secret-content-content $PK_BASE64 --secret-content-name pk --secret-content-stage CURRENT --freeform-tags "{\"${ident}-stripe-pk\": \"\"}"
  oci vault secret create-base64 --compartment-id $compartment_id --secret-name ecom_db_pw --vault-id $vault_id --description stripe_api_sk --key-id $mgmtkey --secret-content-content $DBPW_BASE64 --secret-content-name dbpw --secret-content-stage CURRENT --freeform-tags "{\"${ident}-db-pw\": \"\"}"
}

# Cleanup
function cleanup_logs() {
  rm /tmp/oci-caas-$$-*.log 2>&1 > /dev/null
}
