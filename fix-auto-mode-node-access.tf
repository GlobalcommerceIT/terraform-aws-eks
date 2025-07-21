resource "kubernetes_cluster_role_binding" "eks_admin_rbac" {
  metadata {
    name = "eks-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "User"
    name      = "arn:aws:iam::224607388582:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_GC-AdministratorAccess_c7345ddd4f8d6c19"
    api_group = "rbac.authorization.k8s.io"
  }
}
