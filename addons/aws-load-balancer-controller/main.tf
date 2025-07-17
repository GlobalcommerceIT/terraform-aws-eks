resource "helm_release" "aws-loadbalancer-controller" {
  count      = var.create ? 1 : 0
  name       = var.name
  namespace  = var.namespace
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.chart_version # adjust this to the version you want to use
  set {
    name  = "region"
    value = "us-east-1"
  }

  set {
    name  = "vpcId"
    value = var.eks_cluster_vpc_id
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = var.service_account_name
  }

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }
}
