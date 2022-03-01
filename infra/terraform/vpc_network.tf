
#Create the kube vpc
resource "aws_vpc" "kube_server_vpc" {
  cidr_block           = "${var.kube_server_vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.name}-vpc"
    Environment = "${var.env}"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "kube_server_ig" {
  vpc_id = "${aws_vpc.kube_server_vpc.id}"

  tags = {
    Name = "${var.name}-ig"
    Environment = "${var.env}"
  }

}

# Grant the VPC internet access on its main route table
resource "aws_route" "kube_server_internet_access" {
  route_table_id         = "${aws_vpc.kube_server_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.kube_server_ig.id}"
}

# Create a Subnet w.r.t to availability_zone
resource "aws_subnet" "kube_server_subnet"{
  count                   = "${length(var.aws_availability_zone)}"
  vpc_id                  = "${aws_vpc.kube_server_vpc.id}"
  cidr_block              = "${var.kube_server_vpc_cidr}"
  availability_zone       = "${element(var.aws_availability_zone, count.index)}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-subnet-${element(var.aws_availability_zone, count.index)}"
    Environment = "${var.env}"
  }
}
