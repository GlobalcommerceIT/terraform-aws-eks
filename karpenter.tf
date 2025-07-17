################################################################################
# Karpenter
################################################################################


data "aws_availability_zones" "available" {}
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws
}

module "karpenter" {
  create = var.karpenter_module
  source = "git::git@github.com/GlobalcommerceIT/terraform-aws-eks//modules/karpenter"

  cluster_name                    = var.cluster_name
  irsa_oidc_provider_arn          = aws_iam_openid_connect_provider.oidc_provider[0].arn
  irsa_namespace_service_accounts = ["kube-system:karpenter"]

  # Used to attach additional IAM policies to the Karpenter controller IRSA role
  # policies = {
  #   "xxx" = "yyy"
  # }

  # In this scenario, the Karpenter module will create:
  # - An IAM role for service accounts (IRSA) with a narrowly scoped IAM policy for the Karpenter controller to utilize
  # - An IAM instance profile for the nodes created by Karpenter to utilize
  # - Note: This setup will utilize the existing IAM role created by the EKS Managed Node group which means the role is already populated in the `aws-auth` configmap and no further updates are required.
  # - An SQS queue and Eventbridge event rules for Karpenter to utilize for spot termination handling, capacity rebalancing, etc.

  # Karpenter would run atop the EKS Managed Node group and scale out nodes as needed from there:

  create_iam_role = false
  iam_role_arn    = module.eks_managed_node_group["initial"].iam_role_arn

  # Used to attach additional IAM policies to the Karpenter node IAM role
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    AmazonS3FullAccess                 = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    AmazonSESFullAccess                = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
    AWSAppMeshEnvoyAccess              = "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess"
    AWSAppMeshFullAccess               = "arn:aws:iam::aws:policy/AWSAppMeshFullAccess"
    AWSCloudMapFullAccess              = "arn:aws:iam::aws:policy/AWSCloudMapFullAccess"
    AWSXrayFullAccess                  = "arn:aws:iam::aws:policy/AWSXrayFullAccess"
  }

  tags = var.tags
}


resource "helm_release" "karpenter" {
  namespace           = "kube-system"
  create_namespace    = true
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = var.karpenter_version

  values = [
    <<-EOT
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter.irsa_arn}
    settings:
      clusterName: ${var.cluster_name}
      clusterEndpoint: ${aws_eks_cluster.this[0].endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    controller:
        resources:
          requests:
            cpu: 1
            memory: 1Gi
          limits:
            cpu: 1
            memory: 1Gi
    EOT
  ]


}

###############################
#Migrated to v1beta1
###############################
resource "kubectl_manifest" "karpenter_nodepool_default" {
  yaml_body = <<-YAML
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: default
spec:
  template:
    spec:
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["c"]
        - key: "topology.kubernetes.io/zone"
          operator: In
          values: ["us-east-1a", "us-east-1b", "us-east-1c"]
        - key: karpenter.k8s.aws/instance-size
          operator: NotIn
          values: ["nano", "micro", "small","medium","8xlarge"]
        # - key: karpenter.k8s.aws/instance-family
        #   operator: In
        #   values: ["m5","m5a","r5a"]
        # - key: "karpenter.k8s.aws/instance-cpu"
        #   operator: In
        #   values: ["8"]
        - key: node.kubernetes.io/instance-type
          operator: In
          values: ["c6a.xlarge", "c6a.2xlarge"]
      nodeClassRef:
        apiVersion: karpenter.k8s.aws/v1beta1
        kind: EC2NodeClass
        name: default
  #
  # The snippet below tells Karpenter to only provision a maximum of 1000 CPU cores and 1000Gi of memory. 
  # Karpenter will stop adding capacity only when the limit is met or exceeded. 
  # When a limit is exceeded the Karpenter controller will write memory resource usage 
  # of 1001 exceeds limit of 1000 or a similar looking message to the controllers logs. If you are routing your container logs to CloudWatch logs, you can create a metrics filter to look for specific patterns or terms in your logs and then create a CloudWatch alarm to alert you when your configured metrics threshold is breached.
  #
  limits:
    cpu: 1000
    memory: 1000Gi
  disruption:
    consolidationPolicy: WhenUnderutilized
    #consolidateAfter: 30s
    expireAfter: 720h # 30 * 24h = 720h
YAML

  depends_on = [
    helm_release.karpenter
  ]
}
resource "kubectl_manifest" "karpenter_ec2nodeclass_default" {
  yaml_body = <<-YAML
  apiVersion: karpenter.k8s.aws/v1beta1
  kind: EC2NodeClass
  metadata:
    name: default
  spec:
    amiFamily: AL2023
    amiSelectorTerms:
      - alias: al2023@v20250212
    # 18/2 por restart de nodos al descubrir nuevas amis, se fija a version stable
    role: ${module.eks_managed_node_group["initial"].iam_role_name} 
    #initial-eks-node-group-20240726182942751700000002
    # SGs atachadas a las instancias ec2, tomados por discover de tag
    # securityGroupSelectorTerms:
    # - tags:
    #     karpenter.sh/discovery: ${var.cluster_name}
    securityGroupSelectorTerms:
      - id: ${var.karpenter_sg_nodes}
    # Subnets atachadas a las instancias ec2, tomadas por discover de tag
    subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${var.cluster_name}
    tags:
      karpenter.sh/discovery: ${var.cluster_name}
      Name: eks-karpenter-node
    # blockDeviceMappings:
    #   - deviceName: /dev/xvda
    #     ebs:
    #       volumeSize: 100Gi
    #       volumeType: gp3
    #       encrypted: true
    metadataOptions:
      httpEndpoint: enabled
      httpProtocolIPv6: disabled
      httpPutResponseHopLimit: 2
      httpTokens: required
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

# Example deployment using the [pause image](https://www.ianlewis.org/en/almighty-pause-container)
# and starts with zero replicas
resource "kubectl_manifest" "karpenter_example_deployment" {
  yaml_body = <<-YAML
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: inflate
    spec:
      replicas: 0
      selector:
        matchLabels:
          app: inflate
      template:
        metadata:
          labels:
            app: inflate
        spec:
          terminationGracePeriodSeconds: 0
          containers:
            - name: inflate
              image: public.ecr.aws/eks-distro/kubernetes/pause:3.7
              resources:
                requests:
                  cpu: 1
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}
