
# users keys

output "iam_administrator_access_key" {
  value       = aws_iam_access_key.administrator.id
  description = "Administrator access key"
}
output "iam_administrator_secret_key" {
  value       = aws_iam_access_key.administrator.secret
  description = "Administrator secret key"
}

output "iam_readonly_access_key" {
  value       = aws_iam_access_key.readonly.id
  description = "Readonly access key"
}
output "iam_readonly_secret_key" {
  value       = aws_iam_access_key.readonly.secret
  description = "Readonly secret key"
}

# URLs of our two applications, via their own ELB

output "hello-world-1-elb" {
  value = "http://${kubernetes_service.service_hello_world["hello-world-1"].load_balancer_ingress.0.hostname}:${local.elb_port}/"
}
output "hello-world-2-elb" {
  value = "http://${kubernetes_service.service_hello_world["hello-world-2"].load_balancer_ingress.0.hostname}:${local.elb_port}/"
}

# URLs of our two applications, via nginx-ingress-controller

output "hello-world-1-nginx" {
  value = "http://${kubernetes_service.service_ingress_nginx.load_balancer_ingress.0.hostname}:${local.elb_port}/1/"
}
output "hello-world-2-nginx" {
  value = "http://${kubernetes_service.service_ingress_nginx.load_balancer_ingress.0.hostname}:${local.elb_port}/2/"
}
