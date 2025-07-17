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
  default = "falco"
}
variable "namespace" {
  description = "Namespace to install the release"
  default = "falco"
}
variable "chart_version" {
  description = "Version of the helm chart to install"
  default = "3.8.4"
}