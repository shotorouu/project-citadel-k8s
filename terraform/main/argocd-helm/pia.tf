resource "aws_iam_policy" "ecr_token_refresher" {
  name = "ecr-token-refresher-policy"
  path = "/"

policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:ListImages",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      }
    ]
  })
}

module "ecr_token_refresher_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 1.0"

  name = "ecr-token-refresher-pod-identity-role"

  additional_policy_arns = {
    ecr_token = aws_iam_policy.ecr_token_refresher.arn
  }

  associations = {
    ecr_token_refresher = {
      cluster_name    = var.cluster_name
      namespace       = "argocd"
      service_account = "ecr-token-refresher"
    }
  }

  tags = {
    Environment = "argocd"
  }
}
