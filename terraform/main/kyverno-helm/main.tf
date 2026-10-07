resource "helm_release" "kyverno" {
  name         	   = "kyverno"
  repository       = "https://kyverno.github.io/kyverno/"
  chart     	   = "kyverno"
  version    	   = "3.9.1"
  create_namespace = true
  namespace        = "kyverno"

# Standalone, scale to 3222 for HA
set = [
    {
      name  = "admissionController.replicas"
      value = "1"
    },
    {
      name  = "backgroundController.replicas"
      value = "1"
    },
    {
      name  = "cleanupController.replicas"
      value = "1"
    },
    {
      name  = "reportsController.replicas"
      value = "1"
    }
]
}
