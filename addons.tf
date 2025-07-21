#############################################################################################
## ADDON ARGOCD
#############################################################################################
module "argocd" {
  create = var.argocd_addon
  source = "./addons/argocd"

  eks_cluster_endpoint                   = aws_eks_cluster.this[0].endpoint
  eks_cluster_certificate_authority_data = base64decode(aws_eks_cluster.this[0].certificate_authority[0].data)
  eks_cluster_name                       = var.cluster_name
}
#############################################################################################
## ADDON AWS LOAD BALANCER CONTROLLER
#############################################################################################
module "aws-load-balancer-controller" {
  create = var.aws_load_balancer_controller_addon
  source = "./addons/aws-load-balancer-controller"
  eks_cluster_endpoint                   = aws_eks_cluster.this[0].endpoint
  eks_cluster_certificate_authority_data = base64decode(aws_eks_cluster.this[0].certificate_authority[0].data)
  eks_cluster_name                       = var.cluster_name
  service_account_name                   = kubernetes_service_account.aws_lb_controller_service_account[0].metadata[0].name
  eks_cluster_vpc_id                     = var.vpc_id
  chart_version                          = var.aws_load_balancer_controller_chart_version
}

## IRSA AWS LOAD BALANCER CONTROLLER
module "aws_lb_controller_irsa_role" {
  create_role = var.aws_load_balancer_controller_addon
  source = "git::https://github.com/GlobalcommerceIT/terraform-aws-iam-eks-irsa-for-services.git?ref=main"

  role_name                              = "irsa_loadbalancer_controller-${var.cluster_name}"
  attach_load_balancer_controller_policy = true

  owner       = var.tags.owner
  team        = var.tags.team
  environment = var.tags.environment
  url_repo    = var.tags.repo

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.oidc_provider[0].arn
      namespace_service_accounts = ["kube-system:${var.aws_lb_controller_sa_name}"]
    }
  }
}
# K8S SERVICE ACCOUNT AWS LOAD BALANCER CONTROLLER
resource "kubernetes_service_account" "aws_lb_controller_service_account" {
  count = var.aws_load_balancer_controller_addon ? 1 : 0
  metadata {
    name      = var.aws_lb_controller_sa_name
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.aws_lb_controller_irsa_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

#############################################################################################
## ADDON EXTERNAL-DNS
#############################################################################################
# module "external-dns" {
#   create         = var.external_dns_addon
#   source         = "./addons/external-dns"
#   domain_filters = var.external_dns_domains

#   eks_cluster_endpoint                   = aws_eks_cluster.this[0].endpoint
#   eks_cluster_certificate_authority_data = base64decode(aws_eks_cluster.this[0].certificate_authority[0].data)
#   eks_cluster_name                       = var.cluster_name
#   role_arn                               = module.external_dns_irsa_role.iam_role_arn
#   chart_version                          = var.external_dns_chart_version
# }
# ## IRSA EXTERNAL-DNS
# module "external_dns_irsa_role" {
#   create_role = var.external_dns_addon
#   source = "git::git@github.com/GlobalcommerceIT/terraform-aws-iam-eks-irsa-for-services.git"

#   role_name                  = "irsa_external_dns"
#   attach_external_dns_policy = true
#   hosted_zones               = var.external_dns_domains

#   owner       = var.tags.owner
#   team        = var.tags.team
#   environment = var.tags.environment
#   url_repo    = var.tags.repo
  
#   oidc_providers = {
#     main = {
#       provider_arn               = aws_iam_openid_connect_provider.oidc_provider[0].arn
#       namespace_service_accounts = ["external-dns:${var.external_dns_sa_name}"]
#     }
#   }
# }

## ADDON EXTERNAL-SECRETS
module "external-secrets" {
  create = var.external_secrets_addon
  source = "./addons/external-secrets"

  eks_cluster_endpoint                   = aws_eks_cluster.this[0].endpoint
  eks_cluster_certificate_authority_data = base64decode(aws_eks_cluster.this[0].certificate_authority[0].data)
  eks_cluster_name                       = var.cluster_name
  service_account_name                   = kubernetes_service_account.external_secrets_service_account[0].metadata[0].name
  chart_version                          = var.external_secrets_chart_version
}
module "external_secrets_irsa_role" {
  create_role = var.external_secrets_addon
  source = "git::https://github.com/GlobalcommerceIT/terraform-aws-iam-eks-irsa-for-services.git?ref=main"

  role_name                             = "irsa_aws_external_secrets-${var.cluster_name}"
  attach_external_secrets_policy        = true
  external_secrets_secrets_manager_arns = var.external_secrets_secrets_manager_arns
  external_secrets_ssm_parameter_arns   = var.external_secrets_ssm_parameter_arns

  owner       = var.tags.owner
  team        = var.tags.team
  environment = var.tags.environment
  url_repo    = var.tags.repo
  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.oidc_provider[0].arn
      namespace_service_accounts = ["external-secrets:${var.external_secrets_sa_name}"]
    }
  }
}

resource "kubernetes_service_account" "external_secrets_service_account" {
  count = var.external_secrets_addon ? 1 : 0
  metadata {
    name      = "external-secrets-sa"
    namespace = "external-secrets"
    labels = {
      "app.kubernetes.io/name"      = "external-secrets"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.external_secrets_irsa_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}
## ADDON FALCO
module "falco" {
  create = var.falco_addon
  source = "./addons/falco"

  eks_cluster_endpoint                   = aws_eks_cluster.this[0].endpoint
  eks_cluster_certificate_authority_data = base64decode(aws_eks_cluster.this[0].certificate_authority[0].data)
  eks_cluster_name                       = var.cluster_name
  chart_version                          = var.falco_chart_version
}

## ADDON KEDA
module "keda" {
  create = var.keda_addon
  source = "./addons/keda"

  eks_cluster_endpoint                   = aws_eks_cluster.this[0].endpoint
  eks_cluster_certificate_authority_data = base64decode(aws_eks_cluster.this[0].certificate_authority[0].data)
  eks_cluster_name                       = var.cluster_name
  chart_version                          = var.keda_chart_version
}

## ADDON KUBECOST
module "kubecost" {
  create = var.kubecost_addon
  source = "./addons/kubecost"

  eks_cluster_endpoint                   = aws_eks_cluster.this[0].endpoint
  eks_cluster_certificate_authority_data = base64decode(aws_eks_cluster.this[0].certificate_authority[0].data)
  eks_cluster_name                       = var.cluster_name
}

## ADDON KUBE-PROMETHEUS (PROMETHEUS, PROMETHEUS-OPERATOR, ALERTMANAGER, NODE-EXPORTER, ADAPTER FOR K8S METRICS, GRAFANA)
module "kube-prometheus" {
  create = var.kube_prometheus_addon
  source = "./addons/kube-prometheus"

  eks_cluster_endpoint                   = aws_eks_cluster.this[0].endpoint
  eks_cluster_certificate_authority_data = base64decode(aws_eks_cluster.this[0].certificate_authority[0].data)
  eks_cluster_name                       = var.cluster_name
  chart_version                          = var.kube_prometheus_chart_version
}

## ADDON METRICS-SERVER
module "metrics-server" {
  create = var.metrics_server_addon
  source = "./addons/metrics-server"

  eks_cluster_endpoint                   = aws_eks_cluster.this[0].endpoint
  eks_cluster_certificate_authority_data = base64decode(aws_eks_cluster.this[0].certificate_authority[0].data)
  eks_cluster_name                       = var.cluster_name
}

#############################################################################################
## ADDON APP-MESH
#############################################################################################
module "app-mesh" {
  create = var.app_mesh_addon
  source = "./addons/app-mesh"

  eks_cluster_endpoint                   = aws_eks_cluster.this[0].endpoint
  eks_cluster_certificate_authority_data = base64decode(aws_eks_cluster.this[0].certificate_authority[0].data)
  eks_cluster_name                       = var.cluster_name
  oidc_url                               = aws_eks_cluster.this[0].identity[0].oidc[0].issuer
  oidc_arn                               = aws_iam_openid_connect_provider.oidc_provider[0].arn
}

# IRSA PARA CLOUDWATCH
module "cloudwatch_observability_irsa_role" {
  create_role = var.cloudwatch_observability_addon
  source = "git::https://github.com/GlobalcommerceIT/terraform-aws-iam-eks-irsa-for-services.git?ref=main"

  role_name                              = var.cloudwatch_observability_addon_role_name
  attach_cloudwatch_observability_policy = true

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.oidc_provider[0].arn
      namespace_service_accounts = ["amazon-cloudwatch:cloudwatch-agent"]
    }
  }

  owner       = var.tags.owner
  team        = var.tags.team
  environment = var.tags.environment
  url_repo    = var.tags.repo

}