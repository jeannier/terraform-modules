
This is creating :
- a VPC using the AWS recommended setup for EKS
- an EKS cluster
- an EKS node group for the cluster
- an admin Kubernetes user
- a readonly Kubernetes user
- a kube.config file which can be used for both users
- installing metrics-server
- TODO : all kubernetes logs set to be stored to cloudwatch
- installing nginx-ingress-controller
- two deployment/services for two "hello-app"
- an ingress which is creating an URL for the two apps under the same load-balancer

Outputs :
- credentials for the admin and readonly users
- URLs for each "hello-app" via their own load-balancer
- URLs for each "hello-app" via Nginx-Ingress-Controller, sharing a load-balancer

Steps :
- Install kubectl
- Install Terraform 0.12 or higher
- Edit terraform.tfvars to set the cluster & node group configuration
- Run terraform, it will take around 16 minutes to complete :
```
terraform init
terraform apply
```
- Share with the person using the cluster the access/secret keys of the administrator or readonly user (from the Terraform output), and the kube.config (from the root folder)
- On his computer, the user can run ```aws configure``` to set the AWS cli credentials, and save the kube.config file to ~/.kube/config

