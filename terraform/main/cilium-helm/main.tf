resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.16.5"
  namespace  = "kube-system"

values = [
    yamlencode({
      kubeProxyReplacement = "true"
      k8sServiceHost       = replace(var.cluster_endpoint, "https://", "")
      k8sServicePort       = "443"

      ipam = {
        mode = "eni"
      }
      aws = {
        aws-min-allocate = 8
        aws-pre-allocate = 4
      }
      eni = {
        enabled = true
      }

      routingMode                = "native"
      egressMasqueradeInterfaces = "ens+" # amazon nitor pci slots feature
      enableIPv4PrefixDelegation = true
      enableIPv4Masquerade       = true
      enableBPFMasquerade        = false

      operator = {
        hostNetwork = true
        serviceAccount = {
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.cilium_operator.arn
          }
        }
      }
    })
  ]
}
