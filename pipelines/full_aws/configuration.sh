export ACCOUNT_ID=`aws sts get-caller-identity | jq -r .Account`
echo "Configuring terraform to use vars to be $1"
export BUCKET_CONFIG="bucket=terraform-infrastructure-state-$ACCOUNT_ID"
export KEY_CONFIG="key=remote/$1/terraform.state"
echo $BUCKET_CONFIG
terraform init -backend-config=$BUCKET_CONFIG -backend-config=$KEY_CONFIG
echo "tag = \"$1\"" > terraform.tfvars