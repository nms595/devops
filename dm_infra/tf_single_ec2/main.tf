provider "aws" {
  region  = "eu-west-1"
  profile = "${var.aws_profile}"
}

resource "aws_security_group" "dmt_sg" {
  name        = "dmt-sg"
  description = "firewall rules"
  vpc_id      = "${var.my_vpc}"

  # We might need other ports here as well based on dm team
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

####################### VARIABLES #####################
#######################################################
variable "subnet_pub-1a" {
  description = "Pub Subnet 1a"
  default     = "subnet-027fafea0af1921c4"
}

variable "aws_profile" {
  description = "office or home profile"
  default     = "dminds"
}

variable "my_vpc" {
  description = "office or home vpc"
  default     = "vpc-07cbe2afe815dc96d"
}

variable "k_pair" {
  description = "EC2 keys"
  default     = "dm-kliuch"
}

variable "box_name" {
  description = "EC2 name"
  default     = "dmt_sandbox"
}


###################### MODULES #######################
######################################################
#module "ecs" {
#  source = "./modules/terraform-aws-ecs"
#  name = "dmt-ecs"
#}


######################## MASTER  ######################
#######################################################
resource "aws_instance" "master" {
  ami                    = "ami-3548444c"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.dmt_sg.id}"]
  key_name               = "${var.k_pair}"
  subnet_id              = "${var.subnet_pub-1a}"

  connection {
      type        = "ssh"
      user        = "centos"
      private_key = "${file("./dm-kliuch.pem")}"
      timeout     = "3m"
      host        = "${self.public_ip}"
      #host        = "${self.private_ip}"
    }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "export ANSIBLE_HOST_KEY_CHECKING=False",
      "sudo yum install -y https://centos7.iuscommunity.org/ius-release.rpm",
      "sudo yum install epel-release -y",
      "sudo yum install -y python36u python36u-libs python36u-devel python36u-pip",
      "sudo yum install -y yum-utils device-mapper-persistent-data lvm2",
      "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
      "sudo yum install -y docker-ce",
      "sudo yum-config-manager --enable docker-ce-edge",
      "sudo yum-config-manager --enable docker-ce-test",
      "sudo usermod -aG docker $USER",
      "sudo yum install ansible -y",
      "sudo yum install git wget zip unzip vim supervisor -y",
      #"git clone https://github.com/bitnami/bitnami-docker-wordpress.git",
      "sudo pip3.6 install virtualenv",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo systemctl start docker",
      "sudo systemctl enable docker ",
      "sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux",
      "sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config",
      "sudo hostnamectl set-hostname dmt-sandbox",

      "sudo yum install yum-utils -y",
      "sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm",
      "sudo yum-config-manager --disable remi-php54",
      "sudo yum-config-manager --enable remi-php73",

      #"sudo reboot"
    ]
  }




  #provisioner "local-exec" {
  #  command = "ansible-playbook -u centos -i '${self.public_ip},' --private-key ${var.k_pair} provision.yml" 
  #}

  tags = {
    Name = "${var.box_name}"
  }
}


output "master_ip" {
  value = ["${aws_instance.master.public_ip}"]
}
