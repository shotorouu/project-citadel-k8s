module "iam_oidc_provider" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-oidc-provider"

  url = "https://gitlab.com"
  client_id_list = ["https://gitlab.com"]

  tags = {
    Environment = "aws"
  }
}


data "aws_iam_policy_document" "ci_push" {
  statement {
    sid       = "EcrLogin"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    sid = "EcrPush"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
    resources = [var.ecr_repository_arn]
  }
  statement {
    sid       = "ReportsUpload"
    actions   = ["s3:PutObject"]
    resources = ["${var.reports_bucket_arn}/builds/*"]
  }
}

data "aws_iam_policy_document" "ci_reports" {
  statement {
    sid       = "ReportsUpload"
    actions   = ["s3:PutObject"]
    resources = ["${var.reports_bucket_arn}/builds/*"]
  }
}

resource "aws_iam_policy" "ci_push" {
  name   = "gitlab-ci-push-policy"
  policy = data.aws_iam_policy_document.ci_push.json
}

resource "aws_iam_policy" "ci_reports" {
  name   = "gitlab-ci-reports-policy"
  policy = data.aws_iam_policy_document.ci_reports.json
}

# main branch only: can push images
module "iam_role_gitlab_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role  = true
  role_name    = "gitlab-ci-oidc-role"
  provider_url = "https://gitlab.com"

  oidc_fully_qualified_audiences = ["https://gitlab.com"]
  oidc_fully_qualified_subjects  = ["project_id:86409592:ref_type:branch:ref:main"]

  role_policy_arns = [aws_iam_policy.ci_push.arn]

  depends_on = [module.iam_oidc_provider]
}

# any ref: can only upload reports
module "iam_role_gitlab_reports" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role  = true
  role_name    = "gitlab-ci-reports-role"
  provider_url = "https://gitlab.com"

  oidc_fully_qualified_audiences = ["https://gitlab.com"]
  oidc_subjects_with_wildcards   = ["project_id:86409592:*"]

  role_policy_arns = [aws_iam_policy.ci_reports.arn]

  depends_on = [module.iam_oidc_provider]
}
