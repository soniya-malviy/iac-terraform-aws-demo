# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Lab 05 - ShopSmart Infrastructure Stack
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# This configuration creates a realistic multi-resource stack.
# Pay attention to every place one resource references another --
# each reference creates an implicit dependency in Terraform's graph.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-1"
}

# ---------------------------------------------------------------------
# VPC — The foundation of our network.
# This resource has ZERO dependencies. It is the root of the graph.
# ---------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# ---------------------------------------------------------------------
# Public Subnet — Lives inside the VPC.
# IMPLICIT DEPENDENCY: references aws_vpc.main.id
# Terraform knows the VPC must exist before creating this subnet.
# ---------------------------------------------------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id # <-- implicit dependency on VPC
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet"
    Environment = var.environment
  }
}

# ---------------------------------------------------------------------
# Internet Gateway — Gives the VPC a path to the internet.
# IMPLICIT DEPENDENCY: references aws_vpc.main.id
# This can be created IN PARALLEL with the subnet — both only
# depend on the VPC, not on each other.
# ---------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # <-- implicit dependency on VPC

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# ---------------------------------------------------------------------
# Route Table — Defines routing rules for the VPC.
# IMPLICIT DEPENDENCY: references aws_vpc.main.id
# The default route (0.0.0.0/0) points at the internet gateway,
# so there is also an implicit dependency on the IGW.
# ---------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id # <-- implicit dependency on VPC

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id # <-- implicit dependency on IGW
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

# ---------------------------------------------------------------------
# Route Table Association — Connects the route table to the subnet.
# IMPLICIT DEPENDENCIES: references both the subnet and the route table.
# Terraform will wait for BOTH to exist before creating this.
# ---------------------------------------------------------------------
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id      # <-- implicit dependency on subnet
  route_table_id = aws_route_table.public.id  # <-- implicit dependency on route table
}

# ---------------------------------------------------------------------
# Security Group — Firewall rules for our EC2 instance.
# IMPLICIT DEPENDENCY: references aws_vpc.main.id
# Allows inbound HTTP (port 80) and SSH (port 22).
# ---------------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Allow HTTP and SSH inbound traffic for ShopSmart"
  vpc_id      = aws_vpc.main.id # <-- implicit dependency on VPC

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-web-sg"
    Environment = var.environment
  }
}

# ---------------------------------------------------------------------
# EC2 Instance — The ShopSmart web server.
# IMPLICIT DEPENDENCIES:
#   - references aws_subnet.public.id         (must wait for subnet)
#   - references aws_security_group.web.id    (must wait for SG)
# This is a "leaf" node in the dependency graph — nothing depends on it.
# It will be one of the LAST resources created.
# ---------------------------------------------------------------------
resource "aws_instance" "web" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1)
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id              # <-- implicit dependency on subnet
  vpc_security_group_ids = [aws_security_group.web.id]       # <-- implicit dependency on SG

  tags = {
    Name        = "${var.project_name}-web-server"
    Environment = var.environment
  }
}

# ---------------------------------------------------------------------
# S3 Bucket — Storage for ShopSmart application data.
# This resource has NO dependency on the VPC or any networking resource.
# Terraform can create it IN PARALLEL with the VPC and everything else.
# Look for it in the graph — it will be an independent branch.
# ---------------------------------------------------------------------
resource "aws_s3_bucket" "app_data" {
  bucket_prefix = "${var.project_name}-data-"

  tags = {
    Name        = "${var.project_name}-app-data"
    Environment = var.environment
  }
}
