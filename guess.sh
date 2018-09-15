#!/usr/bin/env bash

set -xeo pipefail

REGEXP_RELEASE_TAG="v([0-9]+\.){2}[0-9]+"

usage() {
  cat <<'EOT'
Usage: run.sh [-a] [-e <environment>] [-h]
  -a     Approved deploy
  -e     Environment name
  -h     Print this help
EOT
}

environment=""

while getopts ':e:ah' args; do
  case "$args" in
    e)
      environment="$OPTARG"
      ;;
    a)
      approved=true
      ;;
    h)
      usage
      exit 0
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

if [[ $approved && "$CIRCLE_TAG" =~ $REGEXP_RELEASE_TAG ]]; then
  aws_env="production"
  aws_default_region="ap-northeast-1"
  aws_account_id="$AWS_ACCOUNT_ID_PRODUCTION"
  aws_iam_role_external_id="$AWS_IAM_ROLE_EXTERNAL_ID_PRODUCTION"
elif [[ $approved && -z $CIRCLE_TAG ]]; then
  aws_env="integration"
  aws_default_region="eu-west-1"
  aws_account_id="$AWS_ACCOUNT_ID_INTEGRATION"
  aws_iam_role_external_id="$AWS_IAM_ROLE_EXTERNAL_ID_INTEGRATION"
elif [[ -z $approved && "$CIRCLE_TAG" =~ $REGEXP_RELEASE_TAG ]]; then
  aws_env="staging"
  aws_default_region="us-west-2"
  aws_account_id="$AWS_ACCOUNT_ID_STAGING"
  aws_iam_role_external_id="$AWS_IAM_ROLE_EXTERNAL_ID_STAGING"
else
  aws_env="development"
  aws_default_region="us-east-1"
  aws_account_id="$AWS_ACCOUNT_ID_DEVELOPMENT"
  aws_iam_role_external_id="$AWS_IAM_ROLE_EXTERNAL_ID_DEVELOPMENT"
fi

cat <<EOT > "aws-envs.sh"
export AWS_ACCOUNT_ID="$aws_account_id"
export AWS_ENV="$aws_env"
export AWS_DEFAULT_REGION="$aws_default_region"
export AWS_IAM_ROLE_ARN="arn:aws:iam::${aws_account_id}:role/circle-ci-role-${aws_env}"
export AWS_IAM_ROLE_EXTERNAL_ID="$aws_iam_role_external_id"
EOT
