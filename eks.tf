module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.34.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.32"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  # Enable IRSA (IAM Roles for Service Accounts)
  enable_irsa = true
    
  /*# Add an inbound rule to the control plane security group
  cluster_security_group_additional_rules = {
    ingress_from_local_machine = {
      description = "Allow HTTPS access from local machine"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["${var.local_machine_ip}/20"]  # Replace with your local machine's IP
    }
  }*/

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

data "aws_caller_identity" "current" {}

resource "aws_key_pair" "eks_key" {
  key_name   = "eks-key"  # Automatically creates a key pair
  public_key = file("~/.ssh/id_rsa.pub")  # Uses the local SSH public key
}

resource "aws_eks_node_group" "eks_nodes" {
  # EKS-managed node group for spot instances
  cluster_name    = module.eks.cluster_name
  node_group_name = "eks-worker-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = module.vpc.private_subnets

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = var.spot_instance_types
  capacity_type = "ON_DEMAND"  # switch to Spot

  remote_access {
    ec2_ssh_key = aws_key_pair.eks_key.key_name
  }

  depends_on = [module.eks]
}

#data "aws_eks_cluster_auth" "cluster" {
#  name = module.eks.cluster_id
  # Ensure this data source is evaluated after the EKS cluster is created
#  depends_on = [module.eks]
#}