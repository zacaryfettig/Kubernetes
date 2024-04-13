resource "aws_iam_role" "eksClusterRole" {
  name = "eksClusterRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

#attach the policy to the IAM Cluster Role
resource "aws_iam_policy_attachment" "clusterIamPolicyAttachment" {
  name = "clusterIamPolicyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  roles = [aws_iam_role.eksClusterRole.name]
}


#IAM Role for the Worker Nodes
#IAM Cluster Roles
resource "aws_iam_role" "workerNodeRole" {
  name = "workerNodeRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}


# worker node role policy attachments
resource "aws_iam_policy_attachment" "workerNodeRolePolicyAttachment" {
  name = "workerNodeRolePolicyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  roles = [aws_iam_role.workerNodeRole.name]
}

resource "aws_iam_policy_attachment" "AmazonEKS_CNI_Policy" {
  name = "eksCniAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  roles = [aws_iam_role.workerNodeRole.name]
}

resource "aws_iam_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  name = "workerNodeRolePolicyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  roles = [aws_iam_role.workerNodeRole.name]
}

resource "aws_iam_policy_attachment" "workerNodeEBSCSIDriverPolicy" {
  name = "workerNodeRolePolicyAttachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  roles = [aws_iam_role.workerNodeRole.name]
}
