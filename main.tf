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

  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  self_managed_node_groups = {
    spot = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1

      instance_types = [var.spot_instance_type]
      capacity_type  = "SPOT"
      spot_price    = var.spot_price

      k8s_labels = {
        Environment = "test"
        NodeGroup   = "spot"
      }

      additional_tags = {
        Name = "spot-node"
      }
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

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