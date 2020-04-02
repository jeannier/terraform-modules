resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = var.cluster_name
  instance_types  = var.node_group_instance_types
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.iam_role_workers.arn
  release_version = var.node_group_release_version
  subnet_ids      = split(",", aws_cloudformation_stack.cfm_stack_vpc.outputs["SubnetIds"])

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]

}

# IAM role which allows the EKS workers to communicate with AWS

resource "aws_iam_role" "iam_role_workers" {
  name               = "${var.cluster_name}-workers"
  assume_role_policy = data.aws_iam_policy_document.iam_policy_document_workers.json
}

data "aws_iam_policy_document" "iam_policy_document_workers" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.iam_role_workers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.iam_role_workers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.iam_role_workers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# hack from https://github.com/hashicorp/terraform/issues/15469#issuecomment-515240849
# we're opening a non-existing file if the node group status isn't "ACTIVE", in order to raise an error
locals {
  assert_node_group = aws_eks_node_group.eks_node_group.status != "ACTIVE" ? file("Node group is not in ACTIVE status") : null
}
