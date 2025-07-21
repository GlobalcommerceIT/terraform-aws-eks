resource "kubectl_manifest" "ingress_argocd" {
  yaml_body = <<-YAML
aapiVersion: eks.amazonaws.com/v1
kind: IngressClassParams
metadata:
  name: alb
spec:
  scheme: internet-facing
  subnets.ids: ${var.argocd_ingress_subnets}
  certificateARNs: ${var.argocd_arn_certificate}

---
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: alb
  annotations:
    # Use this annotation to set an IngressClass as Default
    # If an Ingress doesn't specify a class, it will use the Default
    ingressclass.kubernetes.io/is-default-class: "true"
spec:
  # Configures the IngressClass to use EKS Auto Mode
  controller: eks.amazonaws.com/alb
  parameters:
    apiGroup: eks.amazonaws.com
    kind: IngressClassParams
    # Use the name of the IngressClassParams set in the previous step
    name: alb
---

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/certificate-arn: ${var.argocd_arn_certificate}
    alb.ingress.kubernetes.io/subnets: ${join(",", var.argocd_ingress_subnets)}
spec:
  ingressClassName: alb
  rules:
    - host: ${var.argocd_ingress_host}
      http:
        paths:
        - path: /
          backend:
            service:
              name: argogrpc
              port:
                number: 443
          pathType: Prefix
        - path: /
          backend:
            service:
              name: argocd-server
              port:
                number: 443
          pathType: Prefix

YAML

}


