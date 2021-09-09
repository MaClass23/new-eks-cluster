provider "kubernetes" {
# load_config_file = "false"  # Kubernetes should not load a default kubeconfig file
    host = data.aws_eks_cluster.Ma-cluster.endpoint
    token = data.aws_eks_cluster_auth.Ma-cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.Ma-cluster.certificate_authority.0.data)
}

data "aws_eks_cluster" "Ma-cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "Ma-cluster" {
    name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.1.0"
  # insert the 9 required variables here

  cluster_name  = "Ma-eks-cluster"
  cluster_version = "1.19"  # kubernetes version

  subnets = module.Ma-vpc.private_subnets
  vpc_id = module.Ma-vpc.vpc_id

  tags ={
      environment = "development"
      application = "myapp"
  }
# Worker nodes could either be: 
# self-managed - EC@
# semi-managed - Node Group
# managed - fargate

# These will be self-managed worker nodes
  worker_groups = [ 
      {
          instance_type = "t2.small"
          name = "worker-group-1"
          asg_desired_capacity = 5
      },
      {
        instance_type = "t2.medium"
          name = "worker-group-2"
          asg_desired_capacity =3 
      }
  ]
}