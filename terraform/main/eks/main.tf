module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.k8s_version

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
  }
  create_cloudwatch_log_group = true
  cloudwatch_log_group_retention_in_days = 7

  create_kms_key = true

  endpoint_public_access = true
  endpoint_private_access = true
  enable_cluster_creator_admin_permissions = true

  vpc_id                     = var.vpc_id
  subnet_ids                 = var.private_subnets
  control_plane_subnet_ids   = var.private_subnets
  create_node_security_group = false
  create_security_group      = false
  node_security_group_id     = var.sg_id
  security_group_id          = var.sg_id

  # EKS Managed
  eks_managed_node_groups = {
    cillium-ng = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 8
      desired_size = 3

      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }

    }
  }

  tags = {
    Environment = "eks"
    Terraform   = "true"
  }
}

