# UPDATED: Changed singular 'aws_availability_zone' to plural 'aws_availability_zones'
# This allows access to the .names list in main.tf

data "aws_availability_zones" "first" {
  provider = aws.first_VPC
  state    = "available"
}

data "aws_availability_zones" "second" {
  provider = aws.second_VPC
  state    = "available"
}

data "aws_availability_zones" "third" {
  provider = aws.third_VPC
  state    = "available"
}

data "aws_ami" "first_ami" {
  provider    = aws.first_VPC
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
data "aws_ami" "second_ami" {
  provider    = aws.second_VPC
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
data "aws_ami" "third_ami" {
  provider    = aws.third_VPC
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}