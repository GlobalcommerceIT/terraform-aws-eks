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
variable "values_file" {
  description = "Path to the values file"
  type        = string
  # https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-eks-cost-monitoring.yaml
  default = "manifests/values-eks-cost-monitoring.yaml"
}