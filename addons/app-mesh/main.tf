## kubernetes aws-app-mesh-controller

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  dns_suffix = data.aws_partition.current.dns_suffix
  namespace      = lookup(var.helm, "namespace", "appmesh-system")
  serviceaccount = lookup(var.helm, "serviceaccount", "aws-appmesh-controller")
}

module "irsa" {
  source         = "../iam-role-for-serviceaccount"
  name           = join("-", ["irsa", local.name])
  namespace      = local.namespace
  serviceaccount = local.serviceaccount
  oidc_url       = replace(var.oidc_url,"/(^https://)|(/$)/","")
  oidc_arn       = var.oidc_arn
  policy_arns = [
    format("arn:%s:iam::aws:policy/AWSCloudMapFullAccess", local.partition),
    format("arn:%s:iam::aws:policy/AWSAppMeshFullAccess", local.partition),
    format("arn:%s:iam::aws:policy/AWSAppMeshEnvoyAccess", local.partition),
  ]
  tags = var.tags
}

resource "helm_release" "appmesh" {
  count            = var.create ? 1 : 0
  name             = lookup(var.helm, "name", "appmesh-controller")
  chart            = lookup(var.helm, "chart", "appmesh-controller")
  version          = lookup(var.helm, "version", null)
  repository       = lookup(var.helm, "repository", "https://aws.github.io/eks-charts")
  namespace        = local.namespace
  create_namespace = true
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", true)

  dynamic "set" {
    for_each = merge({
      "region"                                                    = "us-east-1"
      "serviceAccount.name"                                       = local.serviceaccount
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = module.irsa.arn
      "tracing.enabled"                                           = true
      "tracing.provider"                                          = "x-ray"
    }, lookup(var.helm, "vars", {}))
    content {
      name  = set.key
      value = set.value
    }
  }
}