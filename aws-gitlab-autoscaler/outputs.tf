output "cache_bucket" {
  sensitive = false
  value     = "${aws_s3_bucket.gitlab_runner_cache.id}"
}

output "machines_profile" {
  sensitive = false
  value     = "${aws_iam_instance_profile.machine_instance_profile.name}"
}

output "bastion_profile" {
  sensitive = false
  value     = "${aws_iam_instance_profile.bastion_instance_profile.name}"
}

output "bastion_ip" {
  sensitive = false
  value     = "${aws_instance.gitlab_runner.private_ip}"
}

output "bastion_and_machines_security_group_name" {
  sensitive = false
  value     = "${aws_security_group.gitlab_runner_sg.name}"
}
