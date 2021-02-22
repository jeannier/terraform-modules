resource "aws_key_pair" "gitlab_runner_key" {
  key_name   = "${var.name}-key"
  public_key = "${file("${var.ssh_public_key_path}")}"
}
