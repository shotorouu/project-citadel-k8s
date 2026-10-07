data "aws_iam_policy_document" "cilium_operator_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.eks_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cilium-operator"]
    }
  }
}

resource "aws_iam_role" "cilium_operator" {
  name               = "${var.cluster_name}-cilium-operator-role"
  assume_role_policy = data.aws_iam_policy_document.cilium_operator_assume_role.json
}

resource "aws_iam_role_policy_attachment" "cilium_operator_cni" {
  role       = aws_iam_role.cilium_operator.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
