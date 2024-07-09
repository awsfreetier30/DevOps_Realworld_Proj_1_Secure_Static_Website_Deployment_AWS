output "website_url" {
  value       = "https://${var.domain_name}"
  description = "The URL of the deployed website"
}

output "alb_dns_name" {
  value       = aws_lb.website.dns_name
  description = "The DNS name of the Application Load Balancer"
}

output "ec2_instance_public_ip" {
  value       = aws_instance.static_website.public_ip
  description = "The public IP address of the EC2 instance"
}
