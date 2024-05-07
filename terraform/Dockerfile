FROM alpine:latest

# Install Terraform
RUN apk add --update terraform

# Set working directory
WORKDIR /app

# Copy terraform files
COPY . /app

# Initialize and validate Terraform (optional)
RUN terraform init && terraform validate
