# Below resource is to create public key

resource "tls_private_key" "sskeygen_execution" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Below are the aws key pair
resource "aws_key_pair" "kube_key_pair" {
  depends_on = ["tls_private_key.sskeygen_execution"]
  key_name   = "${var.aws_public_key_name}"
  public_key = "${tls_private_key.sskeygen_execution.public_key_openssh}"
}

resource "aws_instance" "kube_instance" {
  depends_on = [
    aws_route.kube_server_internet_access,
    aws_security_group_rule.kube_server_security_group_rule_egress_open,
    aws_security_group_rule.kube_server_security_group_rule_ingress_tcp_open
  ]   
  count         = "${length(var.aws_availability_zone)}"
  ami           = "${lookup(var.aws_amis,var.aws_region)}"
  instance_type = "${var.aws_instance_type}"
  key_name      = "${aws_key_pair.kube_key_pair.id}"
  vpc_security_group_ids = ["${aws_security_group.kube_server_security_group_open.id}"]
  subnet_id     = "${aws_subnet.kube_server_subnet[count.index].id}"

  root_block_device {
    volume_size = 50
  }


  connection {
    user        = "ubuntu"
    host = self.public_ip
    private_key = "${tls_private_key.sskeygen_execution.private_key_pem}"
  }

  provisioner "file" {
      source      = "./kubeadm-config.yaml"
      destination = "/tmp/kubeadm-config.yaml"
  }

  provisioner "file" {
      source      = "./flannel.yaml"
      destination = "/tmp/flannel.yaml"
  }

  provisioner "remote-exec" { 
    inline = [
      "sudo apt update",
      "sudo apt -y install apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable'",
      "sudo apt update",
      "sudo apt -y install docker-ce unzip",
<<EOT
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet=1.19.2-00 kubeadm=1.19.2-00 kubectl=1.19.2-00
sudo cp /tmp/kubeadm-config.yaml /etc/kubernetes/kubeadm-config.yaml
sudo sed -i "s;api_address;$(hostname -i);g" /etc/kubernetes/kubeadm-config.yaml 
sudo kubeadm init --ignore-preflight-errors=NumCPU --config /etc/kubernetes/kubeadm-config.yaml  --upload-certs
sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f /tmp/flannel.yaml
sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf taint nodes --all node-role.kubernetes.io/master-
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo snap install helm --classic
EOT
    ]
  }
  provisioner "local-exec" {
    command = "rm -rf ${aws_key_pair.kube_key_pair.id}.pem; echo '${tls_private_key.sskeygen_execution.private_key_pem}' > ${aws_key_pair.kube_key_pair.id}.pem ; chmod 400 ${aws_key_pair.kube_key_pair.id}.pem"
  }
  tags = {
    Name  = "kube-server-${count.index + 1}"
    Environment = "${var.env}"
  }
  # provisioner "remote-exec" {
  #     when    = destroy
  #     inline = [
  #       "sudo kubeadm reset -f",
  #     ]
  # }  
}

