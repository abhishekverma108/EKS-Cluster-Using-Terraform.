
resource "aws_iam_role" "eks_role" {
  name = "eks_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  # The ARN of the policy you want to apply
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  # The role to which  policy should be applied 
  role = aws_iam_role.eks_role.name
}
resource "aws_eks_cluster" "eks" {
  # Name of the cluster.
  name = "eks"
  # The Amazon Resource Name (ARN) of the IAM role that provides permissions for 
  # the Kubernetes control plane to make calls to AWS API operations on your behalf
  role_arn = aws_iam_role.eks_role.arn
  # Desired Kubernetes master version
  version = "1.24"
  vpc_config {
    # Indicates whether or not the Amazon EKS private API server endpoint is enabled
    endpoint_private_access = false
    # Indicates whether or not the Amazon EKS public API server endpoint is enabled
    endpoint_public_access = true
    # Must be in at least two different availability zones
    subnet_ids = [
      aws_subnet.public-subnet.id,
      aws_subnet.private-subnet.id,

    ]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}