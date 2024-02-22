# SERVER2: 'NODE-SERVER' (with Docker & Kubernetes)
# STEP1: CREATING A SECURITY GROUP FOR DOCKER-K8S
# Description: K8s requires ports 22, 80, 443, 6443, 8001, 10250, 30000-32767
resource "aws_security_group" "my_security_group2" {
  name        = "my-security-group4"
  description = "Allow K8s ports"

  # SSH Inbound Rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH Outbound Rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# STEP2: CREATE A K8S EC2 INSTANCE USING EXISTING PEM KEY
# Note: i. First create a pem-key manually from the AWS console
#      ii. Copy it in the same directory as your terraform code
resource "aws_instance" "my_ec2_instance2" {
  ami                    = "ami-0cf10cdf9fcd62d37"
  instance_type          = "t2.medium" # K8s requires min 2CPU & 4G RAM
  vpc_security_group_ids = [aws_security_group.my_security_group2.id]
  key_name               = "My_Key" # paste your key-name here, do not use extension '.pem'

  # Consider EBS volume 30GB
  root_block_device {
    volume_size = 30    # Volume size 30 GB
    volume_type = "gp2" # General Purpose SSD
  }

  tags = {
    Name = "NODE-SERVER"
  }

  # STEP3: USING REMOTE-EXEC PROVISIONER TO INSTALL TOOLS
  provisioner "remote-exec" {
    # ESTABLISHING SSH CONNECTION WITH EC2
    connection {
      type        = "ssh"
      private_key = file("./My_Key.pem") # replace with your key-name 
      user        = "ec2-user"
      host        = self.public_ip
    }

      inline = [
      "sleep 200",

      # Install Docker
      # REF: https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
      "sudo yum update -y",
      "sudo yum install docker -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo chmod 777 /var/run/docker.sock",
      
      # Install K8s
      # REF: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
      "sudo setenforce 0",
      "sudo sed -i 's/^SELINUX=enforcing$$/SELINUX=permissive/' /etc/selinux/config",
      "cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo",
      "[kubernetes]",
      "name=Kubernetes",
      "baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/",
      "enabled=1",
      "gpgcheck=1",
      "gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key",
      "exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni",
      "EOF",
      "sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes",
      "sudo systemctl enable --now kubelet",
      "sudo kubeadm init --pod-network-cidr=10.244.0.0/16  --ignore-preflight-errors=NumCPU --ignore-preflight-errors=Mem",
      "sudo mkdir -p $HOME/.kube",
      "sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
      "kubectl apply -f https://docs.projectcalico.org/v3.18/manifests/calico.yaml",
      "kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml",
      "kubectl taint nodes --all node-role.kubernetes.io/control-plane-",
      ]
    }
  
}

# STEP3: OUTPUT PUBLIC IP OF EC2 INSTANCE
output "NODE_SERVER_PUBLIC_IP" {
  value = aws_instance.my_ec2_instance2.public_ip
}

# STEP4: OUTPUT PRIVATE IP OF EC2 INSTANCE
output "NODE_SERVER_PRIVATE_IP" {
  value = aws_instance.my_ec2_instance2.private_ip
}
