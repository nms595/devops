provider "aws" {
  region  = "eu-west-1"
  profile = "dminds"
}

module "vpc" {
  source = "terraform-aws-vpc"

  name = "prod-env"
  cidr = "10.200.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.200.1.0/24", "10.200.2.0/24", "10.200.3.0/24"]
  public_subnets  = ["10.200.101.0/24", "10.200.102.0/24", "10.200.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dminds_prod"
  }
}
