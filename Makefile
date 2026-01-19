.PHONY: build deploy init plan apply destroy clean

build:
	@echo "Building Lambda function..."
	@./build.sh

init:
	@echo "Initializing Terraform..."
	@cd terraform && terraform init

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
