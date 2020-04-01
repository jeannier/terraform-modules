
resource "aws_cloudformation_stack" "cfm_stack_vpc" {
  name         = var.vpc_name
  template_url = "https://amazon-eks.s3.us-west-2.amazonaws.com/cloudformation/2020-03-23/amazon-eks-vpc-private-subnets.yaml"
}