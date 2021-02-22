resource "aws_s3_bucket" "gitlab_runner_cache" {
  bucket        = "my-s3-gitlab-${var.name}-cache"
  force_destroy = true
}
