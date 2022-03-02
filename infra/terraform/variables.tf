
#Singapore regions

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-1"
}

variable "aws_availability_zone" {
  description = "AWS availabitiy zone to launch servers."
  default     = [ "us-west-1a"]
}

variable "aws_instance_type" {
  description = "AWS Instance type"
  default     = "t2.medium"
}


variable "aws_public_key_name" {
  default = "kube_aws_rsa"
}

# Ubuntu Server 18.04 LTS (HVM), SSD Volume Type
variable "aws_amis" {
  default = {
    us-west-1 = "ami-009726b835c24a3aa"
  }
}

variable "name" {
  description = "Infrastructure name"
  default = "kube-runner"
}

variable "env" {
  description = "Environment"
  default = "Prod"
}

variable "kube_server_vpc_cidr" {
  description = "VPC CIDR"
  default = "10.2.0.0/24"
}

variable "aws_key" {
  default = "dummy"
}

variable "aws_secret" {
  default = "dummy"
}
# variable "kube_server_security_group_closed_port" {
#   description = "Security group for internal communication"
#   default = "8300,8301,8302"
# }

variable "kube_server_security_group_open_port" {
  description = "Security group for external communication"
  default = "80,443,22,8080,5432,53,6379,6443,all"
}

variable "kube_server_security_group_protocol" {
  description = "Security group for external communication"
  default = ["tcp","udp","all"]
}
