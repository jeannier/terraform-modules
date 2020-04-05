
This will create :
- a VPC using the AWS recommended setup for EKS
- an EKS cluster (control plane kubernetes logs stored in cloudwatch)
- an EKS node group for the cluster
- an admin Kubernetes user
- a readonly Kubernetes user
- a kube.config file which can be used for both users
- installing metrics-server
- installing nginx-ingress-controller
- deployment/services/horizontalpodscaler for a few "hello-word" apps
- an ingress which is creating an URL for each of the apps under the same load-balancer
- autoscaler is setup

Step by step :
- Install kubectl
- Install Terraform 0.12 or higher
- Edit terraform.tfvars to set the cluster & node group configuration
- Run terraform, it will take around 16 minutes to complete :
```
terraform init
terraform apply
```
- Share with the person using the cluster the access/secret keys of the administrator or readonly user (from the Terraform output), and the kube.config (from the root folder)
- On his computer, the user can run ```aws configure``` to set the AWS cli credentials, and save the kube.config file to ```~/.kube/config```

Outputs :
- credentials for the admin and readonly users
- URLs for each "hello-world" apps via the load-balancer of the Nginx-Ingress-Controller

TODO :
- https://github.com/aws/amazon-cloudwatch-logs-for-fluent-bit / https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-logs.html
- Grafana dashboard (using Prometheus data)
- Istio : https://eksworkshop.com/servicemesh_with_istio/install/
