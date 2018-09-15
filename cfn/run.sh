#!/usr/bin/env bash

set -xeuo pipefail

image_name="sns-cfn"

while getopts ':t:e:nlh' args; do
  case "$args" in
    t)
      template_file="$OPTARG"
      template_path="templates/${template_file}"
      ;;
    e)
      environment="$OPTARG"
      ;;
  esac
done

[ -f "$template_path" ] || { echo "Invalid template file: $template_file"; exit 1; }
echo "$environment" | grep -qE '^(development|integration|staging|production)$' || { echo "Invalid environment name: $environment"; exit 1; }

docker image build --tag "$image_name" .

docker container run \
  -it \
  --rm \
  --volume ${PWD}/${template_path}:/workdir/template.yml:ro \
  --volume ${PWD}/deploy.sh:/workdir/deploy.sh:ro \
  --volume ${PWD}/params/${environment}.ini:/workdir/params.ini:ro \
  --volume ${HOME}/.aws:/root/.aws:rw \
  "$image_name" \
  $@
