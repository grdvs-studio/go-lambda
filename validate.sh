#!/bin/bash

# Pre-commit validation script
# This script runs the same checks as the CI pipeline to catch errors early

# Don't use set -e so we can fix issues automatically

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track if any checks fail
FAILED=0

echo -e "${GREEN}Running pre-commit validation...${NC}\n"

# Change to project root directory
cd "$(dirname "$0")"

# ============================================
# Go Validation
# ============================================
echo -e "${YELLOW}[1/5] Checking Go code formatting...${NC}"
cd app
if [ "$(gofmt -s -l . | wc -l)" -gt 0 ]; then
    echo -e "${YELLOW}⚠ Code is not formatted. Auto-fixing...${NC}"
    gofmt -s -w .
    echo -e "${GREEN}✓ Code has been automatically formatted${NC}"
else
    echo -e "${GREEN}✓ Code is properly formatted${NC}"
fi

echo -e "\n${YELLOW}[2/5] Running go vet...${NC}"
if ! go vet ./...; then
    echo -e "${RED}✗ go vet found issues${NC}"
    FAILED=1
else
    echo -e "${GREEN}✓ go vet passed${NC}"
fi

echo -e "\n${YELLOW}[3/5] Running Go tests...${NC}"
if ! go test -v ./...; then
    echo -e "${RED}✗ Tests failed${NC}"
    FAILED=1
else
    echo -e "${GREEN}✓ All tests passed${NC}"
fi

cd ..

# ============================================
# Terraform Validation
# ============================================
echo -e "\n${YELLOW}[4/5] Checking Terraform formatting...${NC}"
cd terraform
if ! terraform fmt -check -recursive > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠ Terraform code is not formatted. Auto-fixing...${NC}"
    terraform fmt -recursive
    echo -e "${GREEN}✓ Terraform code has been automatically formatted${NC}"
else
    echo -e "${GREEN}✓ Terraform code is properly formatted${NC}"
fi

echo -e "\n${YELLOW}[5/5] Validating Terraform configuration...${NC}"
# Initialize Terraform (without backend if backend.tfvars doesn't exist)
if [ -f backend.tfvars ]; then
    if terraform init -backend-config=backend.tfvars -input=false > /dev/null 2>&1; then
        if terraform validate > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Terraform validation passed${NC}"
        else
            echo -e "${RED}✗ Terraform validation failed${NC}"
            terraform validate
            FAILED=1
        fi
    else
        echo -e "${YELLOW}⚠ Could not initialize Terraform with backend. Skipping validation.${NC}"
        echo -e "${YELLOW}  (This is OK if backend.tfvars is not configured)${NC}"
    fi
else
    if terraform init -input=false > /dev/null 2>&1; then
        if terraform validate > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Terraform validation passed${NC}"
        else
            echo -e "${RED}✗ Terraform validation failed${NC}"
            terraform validate
            FAILED=1
        fi
    else
        echo -e "${YELLOW}⚠ Could not initialize Terraform. Skipping validation.${NC}"
    fi
fi

cd ..

# ============================================
# Summary
# ============================================
echo ""
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All validation checks passed!${NC}"
    echo -e "${GREEN}You can safely commit your changes.${NC}"
    echo -e "${YELLOW}Note: If formatting was auto-fixed, please review and stage the changes.${NC}"
    exit 0
else
    echo -e "${RED}✗ Validation failed!${NC}"
    echo -e "${RED}Please fix the issues above before committing.${NC}"
    exit 1
fi
