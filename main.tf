resource "local_file" "pet" { // provider: local, resource: file, and resource name can be anything
    filename = var.filename
    content = "We love pets!"
    file_permission = "0700"
}

resource "random_pet" "my-pet" {
    prefix = var.pet[0]
    separator = var.pet[1]
    length = var.pet[2]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Enable IRSA (IAM Roles for Service Accounts)
  enable_irsa = true

  # Add access entries for the root user
  access_entries = {
    root-user = {
      principal_arn = "arn:aws:iam::${var.account_id}:root"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        }
      }
    }
  }

  # EKS-managed node group for spot instances
  eks_managed_node_groups = {
    spot_node_group = {
      name = "spot-node-group"

      # EC2 instance configuration
      instance_types = var.spot_instance_types
      capacity_type  = "SPOT"

      desired_size = 1
      min_size     = 1
      max_size     = 1

      # SSH key for accessing the nodes
      key_name = "my-key-pair"  # Replace with your SSH key name

      # IAM role for the nodes
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      }

      # Tags for the nodes
      tags = {
        Environment = "test"
        NodeGroup   = "spot"
      }
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"  # Use the latest version of the VPC module

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "test"
  }
}

// terraform init
// terraform plan
// terraform apply
// terraform show
// terraform destroy