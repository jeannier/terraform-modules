variable additional_s3_buckets {
  default = ["my-s3-bucket-1", "my-s3-bucket-2"]
}

variable cidr_blocks {
  default = ["11.0.0.0/8"]
}

variable instance_type {
  default = "t2.micro"
}

variable monitoring_enabled {
  default = true
}

variable name {
  default = "gitlab-autoscaler"
}

# not part of the module
variable ssh_private_key_path {
  default = "~/gitlab-autoscaler/ssh/id_rsa"
}

# not part of the module
variable ssh_public_key_path {
  default = "~/gitlab-autoscaler/ssh/id_rsa.pub"
}

variable subnet_ids {
  default = ["subnet-4j9d7gl1"]
}

variable vpc_id {
  default = "vpc-isejfoisef"
}

# this can be found on
# https://gitlab.com/company/repo/settings/ci_cd#js-runners-settings
# "Use the following registration token during setup: XXX "
# this is NOT THE SAME as a "runner token"
variable gitlab_registration_token {
  default = "posefjposejfpsiejf"
}

# ami used for each of the runners
variable ubuntu_ami {
  default = "ami-fsejfsiejfisefpajf"
}

variable gitlab_runner_version {
  default = "12.4.1"
}
variable docker_version {
  default = "5:19.03.0~3-0~ubuntu-disco"
}
variable docker_machine_version {
  default = "0.16.2"
}
