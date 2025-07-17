resource "helm_release" "kube-prometheus" {
  count      = var.create ? 1 : 0
  name       = var.name
  namespace  = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }
}

resource "kubernetes_namespace" "monitoring" {
  count = var.create ? 1 : 0
  metadata {
    name = var.namespace
  }
}