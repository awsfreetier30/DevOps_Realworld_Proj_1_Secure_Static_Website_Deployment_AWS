# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Data source for the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source for the Route 53 zone
data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}

# EC2 Instance
resource "aws_instance" "static_website" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.website_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              
              # Install git and clone the repository
              yum install -y git
              git clone https://github.com/awsfreetier30/code-test-upwork.git /var/www/html
              
              # Configure Apache to use SSL
              yum install -y mod_ssl
              sed -i 's/^#\(Include conf.modules.d.*ssl.conf\)/\1/' /etc/httpd/conf/httpd.conf
              
              # Restart Apache
              systemctl restart httpd
              EOF

  tags = {
    Name = "StaticWebsiteEc2"
  }
}

# Security Group
resource "aws_security_group" "website_sg" {
  name        = "website_sg"
  description = "Allow inbound traffic for website"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ACM Certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Route 53 record for ACM validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [trimsuffix(each.value.record, ".")]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Add a delay after certificate validation
resource "time_sleep" "wait_for_cert_validation" {
  depends_on      = [aws_acm_certificate_validation.cert]
  create_duration = "1m"
}

# Application Load Balancer
resource "aws_lb" "website" {
  name               = "website-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.website_sg.id]
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = false

  depends_on = [time_sleep.wait_for_cert_validation]
}

# ALB Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.website.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  depends_on = [aws_lb.website, time_sleep.wait_for_cert_validation]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.website.arn
  }
}

# ALB Target Group
resource "aws_lb_target_group" "website" {
  name     = "website-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

# ALB Target Group Attachment
resource "aws_lb_target_group_attachment" "website" {
  target_group_arn = aws_lb_target_group.website.arn
  target_id        = aws_instance.static_website.id
  port             = 80
}

# Data source for default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source for default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Route 53 A record
resource "aws_route53_record" "website" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.website.dns_name
    zone_id                = aws_lb.website.zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_lb.website]
}
