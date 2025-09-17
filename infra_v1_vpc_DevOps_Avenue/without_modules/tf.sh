#!/bin/bash
# YT - How To Structure Terraform Project (3 Levels)
# https://www.youtube.com/watch?v=nMVXs8VnrF4
set -e

apply() {
  cd vpc
  terraform init
  terraform apply -auto-approve
    cd ../ec2
  terraform init
  terraform apply -auto-approve
}

destroy() {
  cd ec2
  terraform destroy -auto-approve
  echo "EC2 is Gone!"
  sleep 2
  cd ../vpc
  terraform destroy -auto-approve
}

case "$1" in
  apply) apply
    ;;
  destroy) destroy
    ;;
  *)
    echo "Usage: $0 {apply|destroy}"
    exit 1
    ;;
esac
