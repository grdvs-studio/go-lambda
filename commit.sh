#!/bin/bash

# Commit script with pre-commit validation
# Usage: ./commit.sh "your commit message"

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check if commit message is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Commit message is required${NC}"
    echo "Usage: ./commit.sh \"your commit message\""
    exit 1
fi

COMMIT_MESSAGE="$1"

echo -e "${YELLOW}Running pre-commit validation...${NC}\n"

# Run validation script
if ! "$SCRIPT_DIR/validate.sh"; then
    echo -e "\n${RED}Validation failed. Commit aborted.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Validation passed. Committing changes...${NC}"

# Stage all changes (including any auto-formatted files)
echo -e "${YELLOW}Staging all changes (including auto-formatted files)...${NC}"
git add -A

# Commit with the provided message
if git commit -m "$COMMIT_MESSAGE"; then
    echo -e "\n${GREEN}✓ Successfully committed: $COMMIT_MESSAGE${NC}"
    echo -e "${GREEN}You can now push your changes with: git push${NC}"
else
    echo -e "\n${RED}✗ Commit failed${NC}"
    exit 1
fi
