data "kubectl_path_documents" "metrics-server-manifests" {
  pattern = "${path.module}/components.yaml"
}

resource "kubectl_manifest" "metrics-server" {
  count     = length(data.kubectl_path_documents.metrics-server-manifests.documents)
  yaml_body = element(data.kubectl_path_documents.metrics-server-manifests.documents, count.index)
}
