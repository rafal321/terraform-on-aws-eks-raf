# /*

# EKS EFS CSI Driver Tutorial (ReadWriteMany) & OIDC: AWS EKS Kubernetes Tutorial - Part 9
# efs-csi driver doesn't support eks pod identity so we need 
#      [1] attach all premissions to kubernetes nodes
#   or [2] use OpenID Connect Provider
# --------------------------------------------

# create efs itself
resource "aws_efs_file_system" "eks" {
  creation_token   = "eks"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true
  tags             = { Name = "tag1_here" }
  lifecycle { ignore_changes = [tags] }
}

# create mount target in each subnet wher workers are
resource "aws_efs_mount_target" "zone_a" {
  file_system_id = aws_efs_file_system.eks.id
  subnet_id      = local.subnets_pri[0]
  # it's sg created by EKS itself
  security_groups = [aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id]
}
resource "aws_efs_mount_target" "zone_b" {
  file_system_id = aws_efs_file_system.eks.id
  subnet_id      = local.subnets_pri[1]
  # it's sg created by EKS itself
  security_groups = [aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id]
}
# ------------
#grant premissions to efs-csi driver to attach volumes to our worker nodes
# 1) because we use openID provider we need to create trust policy 

data "aws_iam_policy_document" "efs_csi_driver" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

# 2) create IAM role and attach this trust policy
resource "aws_iam_role" "efs_csi_driver" {
  name               = "${aws_eks_cluster.eks.name}-efs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.efs_csi_driver.json
}

# 3) aws has managed policy so we use that
resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.efs_csi_driver.name
}

# 4) we deploy it using a helm chart
# we specyfy sa name and we link sa with IAM Role

resource "helm_release" "efs_csi_driver" {
  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  namespace  = "kube-system"
  version    = "3.0.3"
  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }
  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.efs_csi_driver.arn
  }
  depends_on = [
    aws_eks_node_group.eks_ng_private,
    aws_efs_mount_target.zone_a,
    aws_efs_mount_target.zone_b
  ]
}
# # ----------------------

# Optional since we already init helm provider (just to make it self contained)
data "aws_eks_cluster_auth" "eks_v2" {
  name = aws_eks_cluster.eks.name
}
# ----------------------
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

# we create custom kubernetes storage class that uses efs file system and kubernetes provider
resource "kubernetes_storage_class_v1" "efs" {
  metadata { name = "efs" }
  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.eks.id
    directoryPerms   = "700"
  }
  mount_options = ["iam"]
  depends_on    = [helm_release.efs_csi_driver]
}
# tail driver logs to make sure all is good
# kubectl logs -l app.kubernetes.io/instance=aws-efs-csi-driver -n kube-system
# */
# ----------------------------------------
# raf created based on: terraform-on-aws-eks-raf/infra_v5_antonP/A10-example
# this is causing issues if run during creation
resource "kubernetes_storage_class_v1" "ebs" {
  metadata {
    name = "gp3-exp"
    #annotations = { "storageclass.kubernetes.io/is-default-class" = true }
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  parameters = {
    fsType = "ext4"
    type   = "gp3"
  }
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
}

