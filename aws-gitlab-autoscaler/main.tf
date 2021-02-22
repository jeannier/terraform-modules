resource "aws_instance" "gitlab_runner" {
  ami                  = "${var.ubuntu_ami}"
  key_name             = "${aws_key_pair.gitlab_runner_key.key_name}"
  instance_type        = "${var.instance_type}"
  monitoring           = "${var.monitoring_enabled}"
  subnet_id            = "${element(var.subnet_ids, count.index % length(var.subnet_ids))}"
  iam_instance_profile = "${aws_iam_instance_profile.bastion_instance_profile.name}"

  vpc_security_group_ids = [
    "${aws_security_group.gitlab_runner_sg.id}",
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${var.ssh_private_key_path}")}"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
sudo apt-get -y update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common

# docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -y install docker-ce=${var.docker_version}

# gitlab
sudo apt-get -y update
sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/v${var.gitlab_runner_version}/binaries/gitlab-runner-linux-amd64
sudo chmod +x /usr/local/bin/gitlab-runner
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start
sudo systemctl --no-pager status gitlab-runner

#docker-machine
sudo curl -L https://github.com/docker/machine/releases/download/v${var.docker_machine_version}/docker-machine-Linux-x86_64 -o /usr/local/bin/docker-machine && sudo chmod +x /usr/local/bin/docker-machine

# https://gitlab.com/gitlab-org/gitlab-runner/issues/3676
sudo find /root
sudo -i sh -c -l "docker-machine create --driver none --url localhost dummy-machine"
sudo find /root

sudo gitlab-runner register \
  --non-interactive \
  --name "autoscaling-runners" \
  --url "https://gitlab.com/company/" \
  --registration-token "posefjposejfpsiejf" \
  --executor "docker+machine" \
  --limit 8 \
  --docker-image "alpine:3" \
  --docker-privileged=true \
  --docker-disable-cache=true \
  --docker-pull-policy "always" \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
  --cache-type "s3" \
  --cache-s3-bucket-name "my-s3-gitlab-${var.name}-cache" \
  --cache-s3-bucket-location "eu-west-1" \
  --cache-shared=true \
  --machine-idle-nodes 1 \
  --machine-idle-time 1800 \
  --machine-max-builds 100 \
  --machine-off-peak-periods "* * 0-7,18-23 * * mon-fri *,* * * * * sat,sun *" \
  --machine-off-peak-idle-count 0 \
  --machine-off-peak-idle-time 1200 \
  --machine-machine-driver "amazonec2" \
  --machine-machine-name "gitlab-autoscaler-%s" \
  --machine-machine-options "amazonec2-iam-instance-profile=${title(var.name)}-Machine-Profile" \
  --machine-machine-options "amazonec2-region=eu-west-1" \
  --machine-machine-options "amazonec2-zone=c" \
  --machine-machine-options "amazonec2-vpc-id=vpc-0494844" \
  --machine-machine-options "amazonec2-subnet-id=subnet-23423424" \
  --machine-machine-options "amazonec2-private-address-only=true" \
  --machine-machine-options "amazonec2-security-group=${var.name}-sg" \
  --machine-machine-options "amazonec2-security-group-readonly=true" \
  --machine-machine-options "amazonec2-instance-type=m5.xlarge" \
  --machine-machine-options "amazonec2-root-size=80" \
  --machine-machine-options "amazonec2-ami=${var.ubuntu_ami}"

sudo /bin/sed -i 's/concurrent.*/concurrent=10/' /etc/gitlab-runner/config.toml

sudo gitlab-runner restart
sudo systemctl --no-pager status gitlab-runner
sudo gitlab-runner verify

# checking if runner is 'alive'
sudo gitlab-runner verify 2>&1 |  grep alive

# https://gitlab.com/gitlab-org/gitlab-runner/issues/3021
# fail if token contains an underscore
sudo gitlab-runner verify
sudo gitlab-runner verify 2>&1 |  grep alive | grep -v _

# to be able to pull images from ECR
sudo apt-get install amazon-ecr-credential-helper -y

    EOF
    ]
  }
}
