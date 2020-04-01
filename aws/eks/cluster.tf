
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.iam_role_masters.arn

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = split(",", aws_cloudformation_stack.cfm_stack_vpc.outputs["SecurityGroups"])
    subnet_ids              = split(",", aws_cloudformation_stack.cfm_stack_vpc.outputs["SubnetIds"])
  }

  depends_on = [
    aws_cloudformation_stack.cfm_stack_vpc,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy
  ]
}

resource "aws_iam_role" "iam_role_masters" {
  name               = "${var.cluster_name}-master"
  assume_role_policy = data.aws_iam_policy_document.iam_policy_document_masters.json
}

data "aws_iam_policy_document" "iam_policy_document_masters" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  role       = aws_iam_role.iam_role_masters.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  role       = aws_iam_role.iam_role_masters.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# hack from https://github.com/hashicorp/terraform/issues/15469#issuecomment-515240849
# we're opening a non-existing file if the cluster status isn't "ACTIVE", in order to raise an error
locals {
  assert_cluster = aws_eks_cluster.eks_cluster.status != "ACTIVE" ? file("Cluster is not in ACTIVE status") : null
}
