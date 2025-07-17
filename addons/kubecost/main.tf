resource "helm_release" "kubecost" {
  count            = var.create ? 1 : 0
  name             = "kubecost"
  namespace        = "kubecost"
  create_namespace = true
  repository       = "oci://public.ecr.aws/kubecost/"
  chart            = "cost-analyzer"
  version          = "1.106.2" # adjust this to the version you want to use

  values = [
    data.local_file.values[count.index]
  ]

  depends_on = [kubernetes_namespace.kubecost]
}

resource "kubernetes_namespace" "kubecost" {
  count      = var.create ? 1 : 0
  metadata {
    name = "kubecost"
  }
}

data "local_file" "values" {
  count      = var.create ? 1 : 0
  filename = var.values_file
}

