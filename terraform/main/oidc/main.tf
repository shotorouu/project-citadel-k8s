module "iam_oidc_provider" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-oidc-provider"

  url = "https://gitlab.com"
  client_id_list = ["https://gitlab.com"]

  tags = {
    Environment = "aws"
  }
}


module "iam_role_gitlab_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role      = true
  role_name        = "gitlab-ci-oidc-role"
  provider_url     = "https://gitlab.com"

  # Match GitLab claims
  oidc_subjects_with_wildcards = ["project_id:86409592:*"]

  role_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]

  depends_on = [module.iam_oidc_provider]
}
