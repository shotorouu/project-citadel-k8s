module "aws_ecr_repository" {
  source = "./ecr"
}

module "s3_reports" {
  source = "./s3_reports"
}

module "vpc" {
  source = "./vpc"
}

module "oidc" {
  source = "./oidc"
}

module "eks" {
  source           = "./eks"
  vpc_id           = module.vpc.vpc_id
  private_subnets  = module.vpc.private_subnets
  sg_id            = module.vpc.sg_id
}

module "cilium" {
  source                = "./cilium-helm"
  cluster_endpoint      = module.eks.cluster_endpoint
  cluster_name          = module.eks.cluster_name
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  eks_oidc_issuer_url   = module.eks.oidc_issuer_url
}

module "kyverno" {
  source     = "./kyverno-helm"
  depends_on = [module.eks]
}

module "argocd" {
  source       = "./argocd-helm"
  depends_on   = [module.eks, module.aws_ecr_repository]
  pat_token    = var.pat_token
  cluster_name = module.eks.cluster_name
}

