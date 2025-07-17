resource "helm_release" "falco" {
  count = var.create ? 1 : 0

  name       = var.name
  namespace  = var.namespace
  repository = "https://falcosecurity.github.io/charts"
  chart      = "falco"
  version    = var.chart_version # adjust this to the version you want to use

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }
  set {
    name  = "driver.kind"
    value = "ebpf"
  }
  set {
    name  = "tty"
    value = "true"
  }
  # set {
  #   name = "falcosidekick.enabled"
  #   value = "true"
  # }
  depends_on = [kubernetes_namespace.falco]
}

resource "kubernetes_namespace" "falco" {
  count = var.create ? 1 : 0

  metadata {
    name = var.namespace
  }
}
