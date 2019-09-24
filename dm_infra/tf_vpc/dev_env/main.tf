provider "aws" {
  region = "eu-west-1"
  profile = "dminds"
}


module "vpc" {
  source = "./terraform-aws-vpc"

  name = "dev-env"
  cidr = "192.168.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  public_subnets  = ["192.168.101.0/24", "192.168.102.0/24", "192.168.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dminds-dev"
  }
}

