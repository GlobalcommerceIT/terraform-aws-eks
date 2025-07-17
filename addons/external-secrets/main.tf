resource "helm_release" "external-secrets" {
  count      = var.create ? 1 : 0
  name       = var.name
  namespace  = var.namespace
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    =  var.chart_version # adjust this to the version you want to use

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }

  depends_on = [kubernetes_namespace.external-secrets]
}

resource "kubernetes_namespace" "external-secrets" {
  metadata {
    name = var.namespace
  }
}

# resource "kubectl_manifest" "ClusterSecretStore" {
#   count     = var.create ? 1 : 0
#   yaml_body = <<YAML
# apiVersion: external-secrets.io/v1beta1
# kind: ClusterSecretStore
# metadata:
#   name: global-secret-store
# spec:
#   provider:
#     aws:
#       service: SecretsManager
#       region: us-east-1
#       auth:
#         jwt:
#           serviceAccountRef:
#             name: ${var.service_account_name}
#             namespace: ${var.namespace}
# YAML
# }