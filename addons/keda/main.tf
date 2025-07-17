resource "helm_release" "keda" {
  count      = var.create ? 1 : 0
  name       = var.name
  namespace  = var.namespace
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  version    = var.chart_version # adjust this to the version you want to use

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }

  depends_on = [kubernetes_namespace.keda]
}

resource "kubernetes_namespace" "keda" {
  count = var.create ? 1 : 0
  metadata {
    name = var.namespace
  }
}
