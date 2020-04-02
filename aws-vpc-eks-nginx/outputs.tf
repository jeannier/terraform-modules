
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

# URLs of our two applications

output "hello-world-url-elb-1" {
  value = "http://${kubernetes_service.service_hello_world_1.load_balancer_ingress.0.hostname}:${local.elb_port}/"
}
output "hello-world-url-elb-2" {
  value = "http://${kubernetes_service.service_hello_world_2.load_balancer_ingress.0.hostname}:${local.elb_port}/"
}
output "hello-world-url-nginx-1" {
  value = "http://${kubernetes_service.service_ingress_nginx.load_balancer_ingress.0.hostname}:${local.elb_port}/1/"
}
output "hello-world-url-nginx-2" {
  value = "http://${kubernetes_service.service_ingress_nginx.load_balancer_ingress.0.hostname}:${local.elb_port}/2/"
}
