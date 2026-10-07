resource "aws_iam_policy" "argocd_imageupdater_ecr" {
  name        = "argocd-imageupdater-ecr-policy"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages"
        ]
        Resource = "*"
      }
    ]
  })
}

module "argocd_imageupdater_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 1.0"

  name = "argocd-imgupd-pod-identity-role"

  additional_policy_arns = {
    ecr_read = aws_iam_policy.argocd_imageupdater_ecr.arn
  }

  associations = {
    argocd_image_updater = {
      cluster_name    = var.cluster_name
      namespace       = "argocd"
      service_account = "argocd-image-updater"
    }
  }

  tags = {
    Environment = "argocd"
  }

}
