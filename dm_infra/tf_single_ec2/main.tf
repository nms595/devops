provider "aws" {
  region  = "eu-west-1"
  profile = "${var.aws_profile}"
}

resource "aws_security_group" "ss_sg" {
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
  
  ingress {
    from_port   = 5601
    to_port     = 5601
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
  default     = "dmt_sandbox_sarturday_classes"
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
  vpc_security_group_ids = ["${aws_security_group.ss_sg.id}"]
  key_name               = "${var.k_pair}"
  subnet_id              = "${var.subnet_pub-1a}"

  tags = {
    Name = "${var.box_name}"
  }
}


output "master_ip" {
  value = ["${aws_instance.master.public_ip}"]
}
