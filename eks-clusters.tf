
/*
resource "aws_eks_cluster" "eksCluster" {
    name = "eksCluster"
    role_arn = aws_iam_role.eksClusterRole.arn

    vpc_config {
      subnet_ids = [aws_subnet.publicSubnet1.id,aws_subnet.publicSubnet2.id]
    }

    depends_on = [ 
        aws_iam_role.eksClusterRole,
        aws_iam_policy_attachment.clusterIamPolicyAttachment
     ]
}
*/

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8.4"

  vpc_id     = aws_vpc.nextcloudVpc.id
  subnet_ids = [aws_subnet.publicSubnet1.id,aws_subnet.publicSubnet2.id]

  cluster_name                   = "eksCluster"
  cluster_version                = "1.29"
  cluster_endpoint_public_access = true
  cluster_addons = {
//    coredns = {
//      most_recent = true
//    }
//    kube-proxy = {
//      most_recent = true
//    }
    vpc-cni = {
      most_recent = true
    }
    /*
    aws-ebs-csi-driver = {
      most_recent = true
    }
    */
  }
  /*
  eks_managed_node_group_defaults = {

      # Needed by the aws-ebs-csi-driver
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
  }

  */

eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      instance_types = ["t2.micro"]
      capacity_type  = "ON_DEMAND"


    }
  }
      depends_on = [ 
        //aws_ebs_volume.k8Ebs
       // aws_iam_role.eksClusterRole,
       // aws_iam_policy_attachment.clusterIamPolicyAttachment
     ]
}


/*
resource "aws_eks_node_group" "nodeGroup1" {
    cluster_name = aws_eks_cluster.eksCluster.name
    node_group_name = "nodeGroup1"
    node_role_arn = aws_iam_role.workerNodeRole.arn
    scaling_config {
      desired_size = 2
      max_size = 3
      min_size = 2
    }

update_config {
  max_unavailable = 1
}


instance_types = ["t2.micro"]

remote_access {
  ec2_ssh_key = "keypair1"
  source_security_group_ids = [aws_security_group.workerNodeSg.id]
}
subnet_ids = [aws_subnet.publicSubnet1.id,aws_subnet.publicSubnet2.id]

depends_on = [ 
    aws_iam_policy_attachment.workerNodeRolePolicyAttachment,
    aws_iam_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_policy_attachment.AmazonEC2ContainerRegistryReadOnly
 ]
}
*/
/*
resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eksCluster.identity.0.oidc.0.issuer
}
*/