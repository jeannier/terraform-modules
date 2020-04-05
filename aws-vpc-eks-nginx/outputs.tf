
# users keys

output "administrator_access_key" {
  value       = aws_iam_access_key.administrator.id
  description = "Administrator access key"
}
output "administrator_secret_key" {
  value       = aws_iam_access_key.administrator.secret
  description = "Administrator secret key"
}

output "readonly_access_key" {
  value       = aws_iam_access_key.readonly.id
  description = "Readonly access key"
}
output "readonly_secret_key" {
  value       = aws_iam_access_key.readonly.secret
  description = "Readonly secret key"
}

# URLs of our applications, via nginx-ingress-controller

output "applications_urls" {
  value = [
    for app in local.applications :
    "http://${kubernetes_service.service_ingress_nginx.load_balancer_ingress.0.hostname}:${local.elb_port}${app.path}/"
  ]
  description = "Applications URL"
}
