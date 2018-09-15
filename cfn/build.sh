#!/usr/bin/env bash

set -xeuo pipefail

image_name="sns-cfn"

docker image build --tag "$image_name" .
