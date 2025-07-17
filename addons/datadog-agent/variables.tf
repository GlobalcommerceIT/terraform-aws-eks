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

variable "datadog_api_key" {
  description = "API KEY DD"
  type        = string
}

variable "datadog_site" {
  description = "SITE DD"
  type        = string
}

variable "apm_enabled" {
  description = "ENABLED APM TRACE K8S APPS"
  type        = bool
  default     = false
}

variable "datadog_app_key" {
  description = "APP KEY DD"
  type        = string
}

variable "logs_enabled" {
  description = "ENABLED LOGS K8S APPS"
  type        = bool
  default     = false
}

variable "logs_containercollectall_enabled" {
  description = "ENABLED LOGS K8S APPS https://docs.datadoghq.com/agent/basic_agent_usage/kubernetes/#log-collection-setup"
  type        = bool
  default     = false
}

variable "containers_exclude" {
  description = "Excluir containers"
  type        = string
  default     = "kube_namespace:cert-manager kube_namespace:datadog kube_namespace:^kube-$ kube_namespace:amazon-cloudwatch kube_namespace:karpenter kube_namespace:kubecost kube_namespace:ingress-nginx-internal"
}

# Cuales containers voy a excluir de logs
variable "containers_exclude_logs" {
  description = "Excluir containers"
  type        = string
  default     = "kube_namespace:.*"
}
# Cuales containers voy a incluir de logs
variable "containers_include_logs" {
  description = "incluid containers"
  type        = string
  default     = "kube_namespace:^default$"
}

# Habilitar metrics server
# Debido a un "bug" por el cual cuando hay un metric server deployado, por ejemplo, de ked
# da un error https://github.com/kedacore/charts/issues/124
variable "enable_metrics_provider" {
  description = "Habilitar metric provider de DD en el agente"
  type        = bool
  default     = true
}