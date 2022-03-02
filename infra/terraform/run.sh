#!/bin/bash
terraform_path="terraform"
$terraform_path init
$terraform_path destroy -auto-approve
$terraform_path init
$terraform_path plan -out k8.plan
$terraform_path apply -auto-approve
