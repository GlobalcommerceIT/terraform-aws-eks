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
variable "argocd_arn_certificate" {
  description = "argocd ingress ssl certificate, arn"
  default     = "arn:aws:acm:us-east-1:224607388582:certificate/xxyyy"
}
variable "argocd_ingress_subnets" {
  description = "subnets id for argocd ingress"
  default     = "subnet-xxyyy, subnet-yyyxxx"
}
variable "argocd_ingress_host" {
  description = "host name for argocd ingress"
  default     = "argocd.example.com"
}