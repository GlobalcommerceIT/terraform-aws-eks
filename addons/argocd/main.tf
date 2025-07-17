resource "helm_release" "argocd" {
  count      = var.create ? 1 : 0
  name       = var.name
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version # adjust this to the version you want to use

  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_namespace" "argocd" {
  count = var.create ? 1 : 0
  metadata {
    name = var.namespace
  }
}
