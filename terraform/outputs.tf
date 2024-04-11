output "dns_name" {
  description = "DNS name to reach the web server on"
  value       = module.load_balancer.dns_name
}

output "vpc_id" {
  description = "DNS name to reach the web server on"
  value       = module.vpc.vpc_id
}