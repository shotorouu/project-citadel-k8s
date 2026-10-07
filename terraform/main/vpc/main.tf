module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "eks-vpc"

  cidr = "10.0.0.0/16"
  azs                     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets 	  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  	  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway      = true
  enable_vpn_gateway      = true

  # REQUIRED FOR ENVOY GATEWAY / AWS LOAD BALANCERS
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Terraform = "true"
    Environment = "eks"
  }
}


module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = var.sg
  description = "EKS sg"
  vpc_id      = module.vpc.vpc_id

  egress_rules = ["all-all"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all traffic from VPC CIDR including EKS control plane ENIs"
      cidr_blocks = "10.0.0.0/16"
    }
  ]

  ingress_with_self = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All traffic from members of this SG"
    }
  ]

  tags = {
    Environment = "eks"
  }
}

module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.security_group.security_group_id]

# ENDPOINTS for AWS services
  endpoints = {
    s3 = {
      service             = "s3"
      tags                = { Name = "s3-vpc-endpoint" }
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    secretsmanager = {
      service             = "secretsmanager"
      subnet_ids          = module.vpc.private_subnets
    }
    ec2 = {
      service             = "ec2"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    eks = {
      service             = "eks"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
  }

  tags = {
    Owner       = "shotorouu"
    Environment = "eks"
  }
}




