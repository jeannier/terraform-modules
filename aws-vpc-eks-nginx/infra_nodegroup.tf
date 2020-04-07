
# getting the list of the 4 subnets from the VPC cloudformation stack

locals {
  subnets_list = split(",",
    aws_cloudformation_stack.cfm_stack_vpc.outputs["SubnetIds"]
  )
}

# we use a node group per availability zone :
# eks_node_group_01 : eks-vpc-PrivateSubnet01 (eu-west-2a) + eks-vpc-PublicSubnet01 (eu-west-2a)
# eks_node_group_02 : eks-vpc-PrivateSubnet02 (eu-west-2b) + eks-vpc-PublicSubnet02 (eu-west-2b)

resource "aws_eks_node_group" "eks_node_group_01" {

  cluster_name    = var.cluster_name
  instance_types  = var.node_group_instance_types
  node_group_name = "${var.node_group_name}-01"
  node_role_arn   = aws_iam_role.iam_role_workers.arn
  release_version = var.node_group_release_version
  subnet_ids = [
    local.subnets_list[0], # eks-vpc-PrivateSubnet01
    local.subnets_list[2]  # eks-vpc-PublicSubnet01
  ]

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  lifecycle {
    ignore_changes = [
      scaling_config
    ]
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
  ]

}

resource "aws_eks_node_group" "eks_node_group_02" {

  cluster_name    = var.cluster_name
  instance_types  = var.node_group_instance_types
  node_group_name = "${var.node_group_name}-02"
  node_role_arn   = aws_iam_role.iam_role_workers.arn
  release_version = var.node_group_release_version
  subnet_ids = [
    local.subnets_list[1], # eks-vpc-PrivateSubnet02
    local.subnets_list[3]  # eks-vpc-PublicSubnet02
  ]

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  lifecycle {
    ignore_changes = [
      scaling_config
    ]
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
      "sts:AssumeRole"
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

# IAM role which allows the EKS workers to manage the autoscaling

resource "aws_iam_policy" "iam_policy_autoscaling" {
  name        = "${var.cluster_name}_autoscaling_policy"
  description = "Policy to allow autoscaling by Kubernetes"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "autoscaling_attachment" {
  policy_arn = aws_iam_policy.iam_policy_autoscaling.arn
  role       = aws_iam_role.iam_role_workers.id
}

# IAM role which allows the EKS workers to send their logs to Cloudwatch

resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerPolicy" {
  role       = aws_iam_role.iam_role_workers.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# testing the node groups
# using a hack from https://github.com/hashicorp/terraform/issues/15469#issuecomment-515240849
# we're opening a non-existing file if the nodes groups status aren't "ACTIVE", in order to raise an error

locals {
  assert_node_group_01 = aws_eks_node_group.eks_node_group_01.status != "ACTIVE" ? file("Node group 01 is not in ACTIVE status") : null
}
locals {
  assert_node_group_02 = aws_eks_node_group.eks_node_group_02.status != "ACTIVE" ? file("Node group 02 is not in ACTIVE status") : null
}
