# Go Lambda Health Check Function

AWS Lambda function written in Go that returns a health check message, deployed using Terraform.

## GitHub Actions Setup

Configure the following secrets in your GitHub repository:

**Settings → Secrets and variables → Actions → New repository secret**

- `AWS_ACCESS_KEY_ID` - AWS access key ID
- `AWS_SECRET_ACCESS_KEY` - AWS secret access key

### Workflow Variables

You can customize these in `.github/workflows/deploy.yml`:

- `AWS_REGION` - AWS region (default: `us-east-1`)
- `TERRAFORM_VERSION` - Terraform version (default: `1.6.0`)

## Local Development

### Build
```bash
make build
```

### Deploy
```bash
make init    # First time only
make plan    # Review changes
make apply   # Deploy
```

### Test
```bash
curl $(cd terraform && terraform output -raw api_gateway_url)
```

## Project Structure

- `app/` - Go Lambda function code
- `terraform/` - Infrastructure as Code
- `.github/workflows/` - CI/CD workflows
