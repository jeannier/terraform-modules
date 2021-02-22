
Setting up the Gitlab runners in EC2

1 - Setup the variable gitlab_registration_token in variables.tf

2 - Run terraform
```
terraform init
terraform plan
terraform apply
```

3 - find the "runner token" which you can find via :
```
gitlab-runner verify
Runtime platform                arch=amd64 os=linux pid=1754 revision=3afdaba6 version=11.5.0
Running in system-mode.
Verifying runner... is alive    runner=f92j8dnf
```
f92j8dnf is the runner token
