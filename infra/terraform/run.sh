#!/bin/bash
terraform_path="terraform"
$terraform_path init
$terraform_path destroy -auto-approve
$terraform_path init
$terraform_path plan
$terraform_path apply -auto-approve
