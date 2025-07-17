provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

provider "kubernetes" {
  host                   = var.eks_cluster_endpoint
  cluster_ca_certificate = var.eks_cluster_certificate_authority_data

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = var.eks_cluster_endpoint
    cluster_ca_certificate = var.eks_cluster_certificate_authority_data

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = var.eks_cluster_endpoint
  cluster_ca_certificate = var.eks_cluster_certificate_authority_data
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", var.eks_cluster_name]
  }
}


resource "kubernetes_namespace" "datadog" {
  metadata {
    name = "datadog"
  }
}

resource "helm_release" "datadog_agent" {
  name             = "datadog-agent"
  chart            = "datadog"
  repository       = "https://helm.datadoghq.com"
  version          = "3.10.9"
  namespace        = kubernetes_namespace.datadog.id
  create_namespace = true
  timeout          = 10000
  force_update     = true
  depends_on       = [kubernetes_namespace.datadog]

  set_sensitive {
    name  = "datadog.apiKey"
    value = var.datadog_api_key
  }

  # set_sensitive {
  #   name  = "datadog.clusterName"
  #   value = var.eks_cluster_name
  # }

  set_sensitive {
    name  = "datadog.appKey"
    value = var.datadog_app_key
  }

  set {
    name  = "datadog.site"
    value = var.datadog_site
  }

  set {
    name  = "datadog.logs.enabled"
    value = var.logs_enabled
  }

  set {
    name  = "datadog.logs.containerCollectAll"
    value = var.logs_containercollectall_enabled
  }

  set {
    name  = "datadog.leaderElection"
    value = true
  }

  set {
    name  = "datadog.collectEvents"
    value = true
  }

  set {
    name  = "clusterAgent.enabled"
    value = true
  }

  set {
    name  = "clusterAgent.metricsProvider.enabled"
    value = var.enable_metrics_provider
  }

  set {
    name  = "networkMonitoring.enabled"
    value = true
  }

  set {
    name  = "systemProbe.enableTCPQueueLength"
    value = true
  }

  set {
    name  = "systemProbe.enableOOMKill"
    value = true
  }

  set {
    name  = "securityAgent.runtime.enabled"
    value = true
  }

  set {
    name  = "datadog.hostVolumeMountPropagation"
    value = "HostToContainer"
  }

  # Habilitamos APM
  set {
    name  = "datadog.apm.enabled"
    value = var.apm_enabled
  }

  # Habilitamos Logs
  set {
    name  = "datadog.logs.enabled"
    value = var.logs_enabled
  }
  set {
    name  = "datadog.logs.containerCollectAll"
    value = var.logs_containercollectall_enabled
  }

  #exluimos contariners
  set {
    name  = "datadog.containerExclude"
    value = var.containers_exclude
  }

  set {
    name  = "datadog.containerExcludeLogs"
    value = var.containers_exclude_logs
  }

  set {
    name  = "datadog.containerIncludeLogs"
    value = var.containers_include_logs
  }

}

