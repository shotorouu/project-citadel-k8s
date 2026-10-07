resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "10.9.2"
  create_namespace = true
  namespace        = "argocd"

  values = [
    yamlencode({
      configs = {
        repositories = {
          private-repo = {
            url      = "https://gitlab.com/shotorouu/project-citadel-k8s.git"
            username = "oauth2"
            password = var.pat_token
            type     = "git"
          }
        }
      }
    })
  ]
}
