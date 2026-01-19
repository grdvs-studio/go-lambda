#!/bin/bash

set -e

echo "Building Lambda function..."

# Create a temporary directory for the build
BUILD_DIR="app/build"
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

# Build the Go binary for Linux from the app directory
cd app
GOOS=linux GOARCH=arm64 go build -o build/bootstrap main.go

# Create the zip file
cd build
zip ../../bootstrap.zip bootstrap
cd ../..

echo "Build complete! Deployment package: bootstrap.zip"
