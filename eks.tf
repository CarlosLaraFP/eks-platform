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
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"  # Use the dynamically fetched account ID
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"  # Access scope type (e.g., "cluster" or "namespace")
            # namespaces = []  # Optional: Specify namespaces if type is "namespace"
          }
        }
      }
    }
  }
}

resource "aws_key_pair" "eks_key" {
  key_name   = "eks-key"  # Automatically creates a key pair
  public_key = file("~/.ssh/id_rsa.pub")  # Uses the local SSH public key
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
  # Ensure this data source is evaluated after the EKS cluster is created
  depends_on = [module.eks]
}

resource "aws_eks_node_group" "eks_nodes" {
  # EKS-managed node group for spot instances
  cluster_name    = module.eks.cluster_name
  node_group_name = "eks-worker-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = module.vpc.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  instance_types = var.spot_instance_types
  capacity_type = "SPOT"

  remote_access {
    ec2_ssh_key = aws_key_pair.eks_key.key_name
  }

  depends_on = [module.eks]
}