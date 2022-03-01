resource "aws_security_group" "kube_server_security_group_open" {
 name        = "${var.name}-sg-external"
 description = "Security group managed for kube for external "

 vpc_id = "${aws_vpc.kube_server_vpc.id}"
 tags = {
   Name = "${var.name}-sg-external"
   Environment = "${var.env}"
 }
}

resource "aws_security_group_rule" "kube_server_security_group_rule_egress_open" {
 type              = "egress"
 from_port         = 0
 to_port           = 0
 protocol          = "-1"
 cidr_blocks       = ["0.0.0.0/0"]
 description       = "All egress traffic"
 security_group_id = "${aws_security_group.kube_server_security_group_open.id}"
}

resource "aws_security_group_rule" "kube_server_security_group_rule_ingress_tcp_open" {
 count             = "${var.kube_server_security_group_open_port == "default_null" ? 0 : length(split(",",var.kube_server_security_group_open_port))}"
 type              = "ingress"
 from_port         = "${element(split(",", var.kube_server_security_group_open_port), count.index)}"
 to_port           = "${element(split(",", var.kube_server_security_group_open_port), count.index)}"
 protocol          = "tcp"
 cidr_blocks       = ["0.0.0.0/0"]
 description       = ""
 security_group_id = "${aws_security_group.kube_server_security_group_open.id}"
}
