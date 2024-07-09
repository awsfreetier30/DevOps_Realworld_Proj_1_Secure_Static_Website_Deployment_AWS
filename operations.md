# Operations Guide

This document provides instructions for common operational tasks related to the Secure Static Website Deployment on AWS.

## Deploying the Infrastructure

1. Ensure you have Terraform installed and AWS credentials configured.
2. Navigate to the `terraform` directory.
3. Run `terraform init` to initialize the working directory.
4. Run `terraform plan` to review the changes.
5. Run `terraform apply` to create the infrastructure.

## Updating Website Content

1. SSH into the EC2 instance:
   ```
   ssh -i path/to/key.pem ec2-user@<EC2_PUBLIC_IP>
   ```
2. Navigate to `/var/www/html`.
3. Update the content as needed.
4. Restart Apache:
   ```
   sudo systemctl restart httpd
   ```

## Scaling the Infrastructure

To add more EC2 instances:

1. Modify the Terraform configuration to create additional EC2 instances.
2. Add the new instances to the ALB target group.
3. Run `terraform apply` to apply the changes.

## Monitoring

1. Use Amazon CloudWatch to monitor EC2 instance and ALB metrics.
2. Set up CloudWatch Alarms for important metrics like CPU utilization and request count.

## Backup and Disaster Recovery

1. Create regular AMI backups of the EC2 instance.
2. Consider using AWS Backup for automated backups.
3. Implement multi-region deployment for high availability and disaster recovery.

## Troubleshooting

Common issues and their solutions:

1. Website not accessible:
   - Check EC2 instance status
   - Verify ALB health checks
   - Review security group rules

2. SSL certificate issues:
   - Verify ACM certificate status
   - Check Route 53 DNS records

For any other issues, review CloudWatch logs and ALB access logs for more information.