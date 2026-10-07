resource "helm_release" "argocd_image_updater" {
  name             = "argocd-image-updater"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-image-updater"
  version          = "1.3.0"
  create_namespace = true
  namespace        = "argocd"

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = "argocd-image-updater"
      }

      config = {
        git = {
          user  = "argocd-image-updater"
          email = "argocd-image-updater@citadel.internal"
        }
        registries = [
          {
            name        = "AWS ECR"
            prefix      = "183255892104.dkr.ecr.us-east-1.amazonaws.com"
            api_url     = "https://183255892104.dkr.ecr.us-east-1.amazonaws.com"
	    credentials = "pullsecret:argocd/ecr-cred"
          }
        ]
      }
    })
  ]
}
