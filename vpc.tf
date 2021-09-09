provider "aws" {
    region = "us-west-2"
   
}

 data "aws_availability_zones" "azs" {}

module "Ma-vpc" {
  source  = "terraform-aws-modules/vpc/aws"          # source of the module
  version = "3.6.0"
  # insert the 19 required variables here
  # Best practice requires us to create both a public & a private subnet in each availability zone 
  # of the region we are provisioning the EKS cluster

  name = "Ma-vpc"
  cidr =var.vpc_cidr_block
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets = var.public_subnet_cidr_blocks
  azs = data.aws_availability_zones.azs.names   # read all the AZs available in this region

  enable_nat_gateway = true  # by default nat gateway is enabled for the subnets however we will set it as true for transparency 
  single_nat_gateway = true  # creates a shared common nat gateway for all the private subnets (all private subnets will route their traffic through this single NAT gateway)
  enable_dns_hostnames = true

  # These tags enable the K8s cloud controller manager & AWS loadbalancer controller to determine which vpc and subnets it should connect to
  # 
  tags = {
      "kubernetes.io/cluster/Ma-eks-cluster" = "shared"
  }

  public_subnet_tags = {
      "kubernetes.io/cluster/Ma-eks-cluster" = "shared"
      "kubernetes.io/role/elb" = 1
  }
  
  private_subnet_tags = {
      "kubernetes.io/cluster/Ma-eks-cluster" = "shared"
      "kubernetes.io/role/internal-elb" = 1
  }
}