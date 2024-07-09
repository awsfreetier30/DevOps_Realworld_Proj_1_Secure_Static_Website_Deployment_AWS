# Secure Static Website Deployment on AWS

This project provides a Terraform configuration for deploying a secure static website on AWS using EC2, Application Load Balancer (ALB), AWS Certificate Manager (ACM), and Route 53.

## Project Structure

```
secure-static-website-aws/
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
│
├── docs/
│   ├── architecture.md
│   └── operations.md
│
├── .gitignore
├── README.md
└── LICENSE
```

## Prerequisites

- AWS account with appropriate permissions
- Terraform (version 0.14.0 or later)
- AWS CLI configured with your credentials
- Registered domain name in Route 53

## Quick Start

1. Clone this repository:
   ```
   git clone https://github.com/your-username/secure-static-website-aws.git
   cd secure-static-website-aws
   ```

2. Navigate to the Terraform directory:
   ```
   cd terraform
   ```

3. Initialize Terraform:
   ```
   terraform init
   ```

4. Review and modify the `variables.tf` file to match your requirements.

5. Plan the deployment:
   ```
   terraform plan
   ```

6. Apply the configuration:
   ```
   terraform apply
   ```

7. After the deployment is complete, you can access your website using the URL provided in the output.

## Documentation

- For detailed architecture information, see [docs/architecture.md](docs/architecture.md).
- For operational procedures, see [docs/operations.md](docs/operations.md).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.