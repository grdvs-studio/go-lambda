.PHONY: build deploy init init-backend plan apply destroy clean setup-backend

build:
	@echo "Building Lambda function..."
	@./build.sh

setup-backend:
	@echo "Setting up S3 backend for Terraform state..."
	@./s3-backend.sh

init:
	@echo "Initializing Terraform..."
	@if [ -f terraform/backend.tfvars ]; then \
		cd terraform && terraform init -backend-config=backend.tfvars; \
	else \
		echo "⚠️  backend.tfvars not found. Run 'make setup-backend' first or initialize manually."; \
		cd terraform && terraform init; \
	fi

init-backend: setup-backend init

plan: build
	@echo "Planning Terraform deployment..."
	@cd terraform && terraform plan

apply: build
	@echo "Applying Terraform configuration..."
	@cd terraform && terraform apply

destroy:
	@echo "Destroying Terraform resources..."
	@cd terraform && terraform destroy

clean:
	@echo "Cleaning up build artifacts..."
	@rm -rf app/build bootstrap.zip
