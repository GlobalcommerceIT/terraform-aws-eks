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
variable "domain_filters" {
  description = "Domains to include in external dns filters"
  type        = list(string)
  default = [ "" ]
}
variable "name" {
  description = "Name of the release to install"
  default = "external-dns"
}
variable "namespace" {
  description = "Namespace to install the release"
  default = "external-dns"
}
variable "chart_version" {
  description = "Version of the helm chart to install"
  default = "1.13.1"
}
variable "role_arn" {
  description = "The ARN of the service account role"
  type        = string
}