/*
resource "aws_ebs_volume" "k8Ebs" {
availability_zone = var.az1
size = 1
}
*/
/*
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}


locals {
  ebs_csi_irsa_role = module.ebs_csi_irsa_role.iam_role_arn
}


data "aws_iam_policy_document" "csi" {
    statement {
      actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"
    
    condition {
      test = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type = "Federated"
    }  
    }
}

resource "aws_iam_role" "eks_ebs_csi_driver" {
  assume_role_policy = data.aws_iam_policy_document.csi.json
}

resource "aws_iam_role_policy_attachment" "amazon_ebs_csi_driver" {
    role = aws_iam_role.eks_ebs_csi_driver.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}


module "ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = ["kube-system:aws-ebs-csi-driver"]
      thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
      url = aws_eks_cluster.eksCluster.identity[0].oidc[0].issuer
    }
  }
}


data "tls_certificate" "eks" {
  url = aws_eks_cluster.eksCluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
    url = aws_eks_cluster.eksCluster.identity[0].oidc[0].issuer
}
*/
/*
resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = aws_eks_cluster.eksCluster.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn
}



#EBS CSI HELM

resource "helm_release" "ebs_csi_driver" {
name = "aws-ebs-csi-driver"
#namespace = "storage"
repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
chart = "aws-ebs-csi-driver"

set {
  name = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
  type = "string"
  value = module.ebs_csi_irsa_role.iam_role_arn
}
}

/*
resource "kubernetes_storage_class_v1" "storageClassGp2" {
  metadata {
    name = "gp2-encrypted"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
}  
storage_provisioner = "ebs.csi.aws.com"
reclaim_policy = "Delete"
allow_volume_expansion = true
volume_binding_mode = "WaitForFirstConsumer"
}
*/