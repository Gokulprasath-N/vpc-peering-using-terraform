variable "first_region" {
  description = "first region for VPC"
  type = string
  default = "us-east-1"
}
variable "second_region" {
  description = "second region for VPC"
  type = string
  default = "us-west-2"
}
variable "third_region" {
  description = "third region for VPC"
  type = string
  default = "us-east-2"
}

variable "first_VPC_cidr" {
  description = "CIRD block for first vpc"
  type = string
  default = "10.0.0.0/16"
}

variable "second_VPC_cidr" {
  description = "CIRD block for second vpc"
  type = string
  default = "10.1.0.0/16"
}

variable "third_VPC_cidr" {
  description = "CIRD block for third vpc"
  type = string
  default = "10.2.0.0/16"
}

variable "first_VPC_subnet_cidr" {
  description = "CIDR block for the first subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "second_VPC_subnet_cidr" {
  description = "CIDR block for the secondary subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "third_VPC_subnet_cidr" {
  description = "CIDR block for the secondary subnet"
  type        = string
  default     = "10.2.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "first_key_name" {
  description = "Name of the SSH key pair for first VPC instance (us-east-1)"
  type        = string
  default     = ""
}

variable "second_key_name" {
  description = "Name of the SSH key pair for second VPC instance (us-west-1)"
  type        = string
  default     = ""
}
variable "third_key_name" {
  description = "Name of the SSH key pair for third VPC instance (us-south-1)"
  type        = string
  default     = ""
}