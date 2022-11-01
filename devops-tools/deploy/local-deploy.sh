#!/usr/bin/env bash
####################################
# 
# local deploy will run terraform locally and deploy to aws
####################################
#set -euao pipefail
#basePath=$(pwd)
#. "$basePath"/devops/bash-formatting.sh
echo "TF_VAR_VERSION:" $TF_VAR_VERSION
echo "TV_VAR_ENVIRONMENT:" $TF_VAR_environment
exit 0
while [ ! $# -eq 0 ]
do
    case "$1" in
        --env)
            ENVIRONMENT="${2}"
            ;;
    esac
    shift
done

if [[ -z $ENVIRONMENT ]]; then
    err "you need to specify an aws environment with --env"
    exit 1
fi

# if [[ -z  "$AWS_ACCESS_KEY_ID" ]] || [[ -z  "$AWS_SECRET_ACCESS_KEY" ]] | [[ -z  "$AWS_SESSION_TOKEN" ]]; then
#     err "No AWS credentials"
#     exit 1
# fi

#set the path of the terraform to run
if [ "$ENVIRONMENT" == "ops" ]; then
    TERRAFORM_PATH="$basePath/terraform/OPS"
else
    TERRAFORM_PATH="$basePath/terraform/ENV"
fi

# TF_PROPERTIES_PATH="$TERRAFORM_PATH/.."
# cd "$TERRAFORM_PATH"

#info "The AWS Account ID is: $(aws sts get-caller-identity --query "Account" --output text)"
info "Starting local deployment for $ENVIRONMENT"

#####  load environment vars  ######
# info "Loading environment variables for $ENVIRONMENT"
# if [ ! -f "$TF_PROPERTIES_PATH"/properties/default.env ]; then
#     err "properties files can't be found at path $TF_PROPERTIES_PATH when loading environment"
#     exit 1
# fi

# . "$TF_PROPERTIES_PATH"/properties/default.env
# . "$TF_PROPERTIES_PATH"/properties/"$ENVIRONMENT".env

echo "The terraform backend bucket is: ${TERRAFORM_BACKEND_BUCKET}"

exit 0

#### TERRAFORM INIT ######
read -rp "run terraform init? <y/N> " prompt
if [[ "$prompt" =~ [yY](es)* ]] ; then
    info "Checking if the terraform backend S3 bucket exists: ${TERRAFORM_BACKEND_BUCKET}"
    bucket=$(aws s3 ls | grep "$TERRAFORM_BACKEND_BUCKET" | awk '{print $3}' || true)

    if [ -z "$bucket" ]; then
        warn "Unable to find the terraform backend S3 bucket"
        info "Creating the terraform backend S3 bucket"
        aws s3 mb s3://"$TERRAFORM_BACKEND_BUCKET" --region "$TF_VAR_default_region"
        aws s3api put-public-access-block --bucket "$TERRAFORM_BACKEND_BUCKET" --public-access-block-configuration 'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'
        aws s3api put-bucket-encryption --bucket "$TERRAFORM_BACKEND_BUCKET" --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
    else
        succ "Terraform backend S3 bucket: $bucket"
    fi

    warn "Clearing any local terrafom state"
    test ! -e .terraform/ || rm -rf .terraform/

    info "Replicating terraform state from S3 bucket"
    terraform init \
              -upgrade \
              -backend-config="bucket=$TERRAFORM_BACKEND_BUCKET" \
              -backend-config="key=$TF_VAR_project_name" \
              -backend-config="region=$TF_VAR_default_region" \
              -force-copy || { err "There was a problem replicating the terraform state"; exit 1; }

    succ "Terraform state has been replicated"
fi


read -rp "do you want to format the terraform? <y/N> " prompt
if [[ "$prompt" =~ [yY](es)* ]] ; then
    terraform fmt
fi

###### TERRAFORM PLAN #####
read -rp "run terraform plan? <y/N> " prompt
if [[ "$prompt" =~ [yY](es)* ]] ; then
  info "Performing terraform plan for $ENVIRONMENT"
  commitsha=$(git rev-parse HEAD)
  TF_PLAN="${commitsha}-${ENVIRONMENT}.tfplan" 


  info "Planning terraform"
  terraform plan \
            -var-file="$TF_PROPERTIES_PATH/properties/default.tfvars" \
            -var-file="$TF_PROPERTIES_PATH/properties/$ENVIRONMENT.tfvars" \
            -out="${basePath}/${TF_PLAN}" || { err "There was a problem with the terraform plan"; exit 1; }
  
  succ "Terraform plan has completed"

fi

commitsha=$(git rev-parse HEAD)
TF_PLAN="${commitsha}-${ENVIRONMENT}.tfplan" 


