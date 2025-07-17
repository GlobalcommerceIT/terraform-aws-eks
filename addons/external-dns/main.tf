resource "helm_release" "external_dns" {
  count      = var.create ? 1 : 0
  name       = var.name
  namespace  = var.namespace
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  version    = var.chart_version

  values = [
    templatefile(
      "${path.module}/values.yaml.tpl",
      {
        domainFilters       = var.domain_filters
        cluster             = var.eks_cluster_name
        eks_service_account = var.role_arn
      }
    )
  ]
  depends_on = [kubernetes_namespace.external_dns]
}

resource "kubernetes_namespace" "external_dns" {
  count = var.create ? 1 : 0
  metadata {
    name = var.namespace
  }
}
