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