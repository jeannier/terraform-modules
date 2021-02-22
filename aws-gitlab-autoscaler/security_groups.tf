resource "aws_security_group" "gitlab_runner_sg" {
  name        = "${var.name}-sg"
  description = "Allow internal access to gitlab runners"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_blocks}"]
    self        = true
  }

  ingress {
    from_port = 2376
    to_port   = 2376
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 3376
    to_port   = 3376
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
