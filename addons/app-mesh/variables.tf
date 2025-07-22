### helm
variable "helm" {
  description = "The helm release configuration"
  type        = any
  default = {
    name            = "appmesh-controller"
    repository      = "https://aws.github.io/eks-charts"
    chart           = "appmesh-controller"
    namespace       = "appmesh-system"
    serviceaccount  = "aws-appmesh-controller"
    cleanup_on_fail = true
    vars            = {}
  }
}


variable "petname" {
  description = "An indicator whether to append a random identifier to the end of the name to avoid duplication"
  type        = bool
  default     = true
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}

variable "create" {
  description = "Flag to wether create or not the resource"
  default     = false
}
variable "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  type        = string
}
variable "eks_cluster_certificate_authority_data" {
  description = "The cert of the EKS cluster"
  type        = string
}
variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}
variable "name" {
  description = "Name of the release to install"
  default = "argocd"
}
variable "namespace" {
  description = "Namespace to install the release"
  default = "argocd"
}
variable "chart_version" {
  description = "Version of the helm chart to install"
  default = "5.46.8"
}

variable "oidc_url" {
  description = "A URL of the OIDC Provider"
  type        = string
}

variable "oidc_arn" {
  description = "An ARN of the OIDC Provider"
  type        = string
}

variable "app_mesh_addon_trace" {
  description = "Flag to enable app-mesh x-ray trace on the cluster"
  default     = true
}

