data "aws_subnet_ids" "private" {
  vpc_id = "${var.vpc_id}"
}

data "aws_caller_identity" "current" {}
