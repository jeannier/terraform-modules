# creating the two IAM users
resource "aws_iam_user" "administrator" {
  name = "${var.cluster_name}-administrator"
}
resource "aws_iam_access_key" "administrator" {
  user = aws_iam_user.administrator.name
}
resource "aws_iam_user" "readonly" {
  name = "${var.cluster_name}-readonly"
}
resource "aws_iam_access_key" "readonly" {
  user = aws_iam_user.readonly.name
}
