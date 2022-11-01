#!/usr/bin/env bash
####################################
# 
# local deploy will run terraform locally and deploy to aws
####################################
set -euao pipefail
. ./message-formatting.sh

#ask a question (First param), return true/false boolean depending on answer
function checkUserConsent() {
    echo $1 " - Type y[es] to continue" > /dev/tty
    read -rp "User input <y/N> " prompt
    if [[ "$prompt" =~ [yY](es)* ]] ; then
        echo 1
    else
        echo 0
    fi
}

# first param is true|false, second param is an error message
function errorOnFalse() {
    if [[ $1 -eq 0 ]]; then
        err "$2"
        exit 1
    fi
}


# Prerequesite checks
if [[ -z $TF_VAR_ENVIRONMENT ]]; then
    errorOnFalse 0 "You need to specify an aws environment eg 'tf-ops', check your env vars, please see the README.md, this script should be run using NX/Lerna which will load a .env file automagically."
fi


if [[ -z  "$AWS_ACCESS_KEY_ID" ]] || [[ -z  "$AWS_SECRET_ACCESS_KEY" ]] | [[ -z  "$AWS_SESSION_TOKEN" ]]; then
     errorOnFalse 0 "No AWS credentials, please manually set your AWS credentials as environment vars"
fi

ssm_terraform_backend_bucket=$(echo $(aws ssm get-parameters --names "TERRAFORM_BACKEND_BUCKET") | jq --arg pn "TERRAFORM_BACKEND_BUCKET" -r '.Parameters[] | select(.Name == $pn) | .Value')
if (( $ssm_terraform_backend_bucket != $TERRAFORM_BACKEND_BUCKET )); then
   warn "The current Terraform backend bucket does not match the one that was previously used on this AWS account"
   warn "Only proceed if you are absolutely sure you know what you are doing"
   checkUserConsent "Do you want to continue?" error
fi
   
   
#setting up paths
rootPath=$(pwd)/../..
if [ "$TF_VAR_ENVIRONMENT" == "ops" ]; then
    TERRAFORM_PATH="$rootPath/terraform/OPS"
else
    TERRAFORM_PATH="$rootPath/terraform/ENV"
fi

TF_PROPERTIES_PATH="$TERRAFORM_PATH/.."
info "rootPath: $rootPath"
info "Environment: $TF_VAR_ENVIRONMENT"
info "AWS Account ID: $(aws sts get-caller-identity --query "Account" --output text)"
info "Terraform files:  $TERRAFORM_PATH"
info "Terraform Version: $TF_VAR_VERSION"
info "AWS provider Version: $TF_VAR_AWS_VERSION"
info "Backend bucket is: ${TERRAFORM_BACKEND_BUCKET}"

errorOnFalse \
    $(checkUserConsent "Do you want to run the deploy script?") \
    "Exiting by user"

info "Starting local deployment for $TF_VAR_ENVIRONMENT"

# Check for backend bucket and prompt to create it if not present
info "Checking if the terraform backend S3 bucket exists: ${TERRAFORM_BACKEND_BUCKET}"
bucket=$(aws s3 ls | grep "$TERRAFORM_BACKEND_BUCKET" | awk '{print $3}' || true)
if [ -z "$bucket" ]; then
    warn "Unable to find the terraform backend S3 bucket: $TERRAFORM_BACKEND_BUCKET"
    errorOnFalse \
        $(checkUserConsent "Would you like to create the terraform backend bucket: $TERRAFORM_BACKEND_BUCKET?") \
        "You need to create a backend bucket to run the deploy"

    info "Creating the terraform backend S3 bucket"    
    aws s3 mb s3://"$TERRAFORM_BACKEND_BUCKET" \
        --region "$TF_VAR_default_region"
    aws s3api put-public-access-block \
        --bucket "$TERRAFORM_BACKEND_BUCKET" \
        --public-access-block-configuration 'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'
    aws s3api put-bucket-encryption \
        --bucket "$TERRAFORM_BACKEND_BUCKET" \
        --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
else
    succ "Terraform backend S3 bucket exists, using: $bucket"
fi

#### TERRAFORM INIT ######
if [[ $(checkUserConsent "terraform init?") -eq 1 ]]; then
    warn "Clearing any local terrafom state"
    rm -rf .terraform/

    info "Replicating terraform state from $TERRAFORM_BACKEND_BUCKET"
    terraform init \
              -upgrade \
              -backend-config="bucket=$TERRAFORM_BACKEND_BUCKET" \
              -backend-config="key=$TF_VAR_PROJECT_NAME" \
              -backend-config="region=$TF_VAR_DEFAULT_REGION" \
              -force-copy || { err "There was a problem replicating the terraform state"; exit 1; }

    succ "Terraform state has been replicated"
fi


###### TERRAFORM PLAN #####

commitsha=$(git rev-parse HEAD)
TF_PLAN="${commitsha}-${ENVIRONMENT}.tfplan"
planFound=0
until [[ $planFound -eq 1 ]]; do
    if [[ $(checkUserConsent "terraform plan?") -eq 1 ]]; then
        info "Performing terraform plan for $TF_VAR_ENVIRONMENT"
        commitsha=$(git rev-parse HEAD)
        TF_PLAN="${commitsha}-${ENVIRONMENT}.tfplan" 


        info "Planning terraform"
        terraform plan \
                  -var-file="$TF_PROPERTIES_PATH/properties/default.tfvars" \
                  -var-file="$TF_PROPERTIES_PATH/properties/$ENVIRONMENT.tfvars" \
                  -out="${rootPath}/${TF_PLAN}" || { err "There was a problem with the terraform plan"; exit 1; }
        
        succ "Terraform plan has completed"
        planFound=1
    else
        if [[ -f $rootPath/$TF_PLAN ]]; then
            info "Using local plan $rootPath/$TF_PLAN"
            planFound=1
        else
            s3PlanCheck=$(aws s3 ls s3://$TF_PLAN_BUCKET/$TF_PLAN | cat)
            if [ "$s3PlanCheck" != "" ]; then
                info "Downloading Terraform Plan from $_TF_PLAN_BUCKET"
                aws s3 cp s3://$TF_PLAN_BUCKET/$TF_PLAN $rootPath/$TF_PLAN
                planFound=1
            fi
        fi
    fi
    
    if [[ $planFound -eq 0 ]]; then
        warn "You need a terraform plan to continue."
        errorOnFalse $(checkUserConsent "Exit? (no will ask you to create a plan again).") "Exited by user"
    fi
done


if [[ $(checkUserConsent "Save terraform plan to $TF_PLAN_BUCKET?") -eq 1 ]]; then
    info "Checking if the terraform plan S3 bucket exists"
    bucket=$(aws s3 ls | grep "$TF_PLAN_BUCKET" | awk '{print $3}' || true)
    if [ -z "$bucket" ]; then
        warn "Unable to find the terraform backend S3 bucket"
        if [[ $(checkUserConsent "Create $TF_PLAN_BUCKET?") -eq 1 ]]; then
            info "Creating the terraform backend S3 bucket"
            aws s3 mb s3://"$TF_PLAN_BUCKET" \
                --region "$TF_VAR_DEFAULT_REGION"
            aws s3api put-public-access-block \
                --bucket "$TF_PLAN_BUCKET" \
                --public-access-block-configuration 'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'
            aws s3api put-bucket-encryption \
                --bucket "$TF_PLAN_BUCKET" \
                --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
            aws s3api put-bucket-lifecycle \
                --bucket "$TF_PLAN_BUCKET" \
                --lifecycle-configuration '{"Rules": [{"ID": "plan-housekeeping", "Prefix": "/", "Status": "Enabled", "Expiration": { "Days": 30}}]}'
        fi
    fi
    bucket=$(aws s3 ls | grep "$TF_PLAN_BUCKET" | awk '{print $3}' || true)
    if [ -z "$bucket" ]; then
        warn "unable to save Terraform plan as $TF_PLAN_BUCKET does not exist"
    else
        info "Uploading Terraform Plan"
        aws s3 cp "$rootPath"/"$TF_PLAN" s3://"$TF_PLAN_BUCKET"/"$TF_PLAN" --acl private
        succ "$TF_PLAN had been uploaded to $TF_PLAN_BUCKET"
    fi
fi

if [[ $(checkUserConsent "terraform APPLY?") -eq 1 ]]; then
    info "Applying terraform changes"
    terraform apply -auto-approve "$rootPath/${TF_PLAN}" || errorOnFalse 0 "Unable to complete terraform apply" 
    aws ssm put-parameter  --name "TERRAFORM_BACKEND_BUCKET"  --type "String"  --value $TERRAFORM_BACKEND_BUCKET  --overwrite
fi
