# -----------------------------------------------------------
# VPC DEFINITIONS
# -----------------------------------------------------------

resource "aws_vpc" "first_VPC" {
  provider             = aws.first_VPC
  cidr_block           = var.first_VPC_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "first_VPC-${var.first_region}"
    environment = "Demo"
    purpose     = "VPC peering demo"
  }
}

resource "aws_vpc" "second_VPC" {
  provider             = aws.second_VPC
  cidr_block           = var.second_VPC_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "second_VPC-${var.second_region}"
    environment = "Demo"
    purpose     = "VPC peering demo"
  }
}

resource "aws_vpc" "third_VPC" {
  provider             = aws.third_VPC
  cidr_block           = var.third_VPC_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "third_VPC-${var.third_region}"
    environment = "Demo"
    purpose     = "VPC peering demo"
  }
}

# -----------------------------------------------------------
# SUBNETS
# -----------------------------------------------------------

resource "aws_subnet" "first_VPC_subnet" {
  provider                = aws.first_VPC
  vpc_id                  = aws_vpc.first_VPC.id
  cidr_block              = var.first_VPC_subnet_cidr
  availability_zone       = data.aws_availability_zones.first.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "Primary-Subnet-${var.first_region}"
    Environment = "Demo"
  }
}

resource "aws_subnet" "second_VPC_subnet" {
  provider                = aws.second_VPC
  vpc_id                  = aws_vpc.second_VPC.id
  cidr_block              = var.second_VPC_subnet_cidr
  availability_zone       = data.aws_availability_zones.second.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "Secondary-Subnet-${var.second_region}"
    Environment = "Demo"
  }
}

resource "aws_subnet" "third_VPC_subnet" {
  provider                = aws.third_VPC
  vpc_id                  = aws_vpc.third_VPC.id
  cidr_block              = var.third_VPC_subnet_cidr
  availability_zone       = data.aws_availability_zones.third.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "Tertiary-Subnet-${var.third_region}"
    Environment = "Demo"
  }
}

# -----------------------------------------------------------
# INTERNET GATEWAYS
# -----------------------------------------------------------

resource "aws_internet_gateway" "first_igw" {
  provider = aws.first_VPC
  vpc_id   = aws_vpc.first_VPC.id
  tags = {
    Name        = "first-igw"
    environment = "demo"
  }
}

resource "aws_internet_gateway" "second_igw" {
  provider = aws.second_VPC
  vpc_id   = aws_vpc.second_VPC.id
  tags = {
    Name        = "second-igw"
    environment = "demo"
  }
}

resource "aws_internet_gateway" "third_igw" {
  provider = aws.third_VPC
  vpc_id   = aws_vpc.third_VPC.id
  tags = {
    Name        = "third-igw"
    environment = "demo"
  }
}

# -----------------------------------------------------------
# ROUTE TABLES
# NOTE: Removed inline 'route' blocks to avoid conflicts
# -----------------------------------------------------------

resource "aws_route_table" "first_rt" {
  provider = aws.first_VPC
  vpc_id   = aws_vpc.first_VPC.id
  tags = {
    name        = "first-route_table"
    environment = "demo"
  }
}

resource "aws_route_table" "second_rt" {
  provider = aws.second_VPC
  vpc_id   = aws_vpc.second_VPC.id
  tags = {
    name        = "second-route_table"
    environment = "demo"
  }
}

resource "aws_route_table" "third_rt" {
  provider = aws.third_VPC
  vpc_id   = aws_vpc.third_VPC.id
  tags = {
    name        = "third-route_table"
    environment = "demo"
  }
}

# -----------------------------------------------------------
# IGW ROUTES (Moved out of Route Table for consistency)
# -----------------------------------------------------------

resource "aws_route" "first_internet_access" {
  provider               = aws.first_VPC
  route_table_id         = aws_route_table.first_rt.id
  destination_cidr_block = "0.0.0.0/0" # Usually 0.0.0.0/0 for IGW, not specific CIDR
  gateway_id             = aws_internet_gateway.first_igw.id
}

resource "aws_route" "second_internet_access" {
  provider               = aws.second_VPC
  route_table_id         = aws_route_table.second_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.second_igw.id
}

resource "aws_route" "third_internet_access" {
  provider               = aws.third_VPC
  route_table_id         = aws_route_table.third_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.third_igw.id
}

# -----------------------------------------------------------
# ROUTE TABLE ASSOCIATIONS
# -----------------------------------------------------------

resource "aws_route_table_association" "first_rta" {
  provider       = aws.first_VPC
  subnet_id      = aws_subnet.first_VPC_subnet.id
  route_table_id = aws_route_table.first_rt.id
}

resource "aws_route_table_association" "second_rta" {
  provider       = aws.second_VPC
  subnet_id      = aws_subnet.second_VPC_subnet.id
  route_table_id = aws_route_table.second_rt.id
}

resource "aws_route_table_association" "third_rta" {
  provider       = aws.third_VPC
  subnet_id      = aws_subnet.third_VPC_subnet.id
  route_table_id = aws_route_table.third_rt.id
}

# -----------------------------------------------------------
# SECURITY GROUPS
# -----------------------------------------------------------

resource "aws_security_group" "first_sg" {
  provider    = aws.first_VPC
  name        = "first-vpc-sg"
  description = "Security group for First VPC"
  vpc_id      = aws_vpc.first_VPC.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from Peer VPCs"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.second_VPC_cidr, var.third_VPC_cidr]
  }

  ingress {
    description = "All TCP from Peer VPCs"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.second_VPC_cidr, var.third_VPC_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "First-VPC-SG"
    Environment = "Demo"
  }
}

resource "aws_security_group" "second_sg" {
  provider    = aws.second_VPC
  name        = "second-vpc-sg"
  description = "Security group for Second VPC"
  vpc_id      = aws_vpc.second_VPC.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from Peer VPCs"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.first_VPC_cidr, var.third_VPC_cidr]
  }

  ingress {
    description = "All TCP from Peer VPCs"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.first_VPC_cidr, var.third_VPC_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Second-VPC-SG"
    Environment = "Demo"
  }
}

resource "aws_security_group" "third_sg" {
  provider    = aws.third_VPC
  name        = "third-vpc-sg"
  description = "Security group for Third VPC"
  vpc_id      = aws_vpc.third_VPC.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP from Peer VPCs"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.first_VPC_cidr, var.second_VPC_cidr]
  }

  ingress {
    description = "All TCP from Peer VPCs"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.first_VPC_cidr, var.second_VPC_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Third-VPC-SG"
    Environment = "Demo"
  }
}

# -----------------------------------------------------------
# PEERING CONNECTION 1 <-> 2
# -----------------------------------------------------------

# Requester
resource "aws_vpc_peering_connection" "first_second_peering" {
  provider    = aws.first_VPC
  vpc_id      = aws_vpc.first_VPC.id
  peer_vpc_id = aws_vpc.second_VPC.id
  peer_region = var.second_region
  tags = {
    Name = "first-second-peering"
  }
}

# Accepter (Required for Cross-Region)
resource "aws_vpc_peering_connection_accepter" "first_second_accepter" {
  provider                  = aws.second_VPC
  vpc_peering_connection_id = aws_vpc_peering_connection.first_second_peering.id
  auto_accept               = true
  tags = {
    Name = "first-second-peering-accepter"
  }
}

resource "aws_route" "first_to_second_route" {
  provider                  = aws.first_VPC
  route_table_id            = aws_route_table.first_rt.id
  destination_cidr_block    = aws_vpc.second_VPC.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.first_second_peering.id
}

resource "aws_route" "second_to_first_route" {
  provider                  = aws.second_VPC
  route_table_id            = aws_route_table.second_rt.id
  destination_cidr_block    = aws_vpc.first_VPC.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.first_second_peering.id
}

# -----------------------------------------------------------
# PEERING CONNECTION 1 <-> 3
# -----------------------------------------------------------

# Requester
resource "aws_vpc_peering_connection" "first_third_peering" {
  provider    = aws.first_VPC
  vpc_id      = aws_vpc.first_VPC.id
  peer_vpc_id = aws_vpc.third_VPC.id
  peer_region = var.third_region
  tags = {
    Name = "first-third-peering"
  }
}

# Accepter
resource "aws_vpc_peering_connection_accepter" "first_third_accepter" {
  provider                  = aws.third_VPC
  vpc_peering_connection_id = aws_vpc_peering_connection.first_third_peering.id
  auto_accept               = true
  tags = {
    Name = "first-third-peering-accepter"
  }
}

resource "aws_route" "first_to_third_route" {
  provider                  = aws.first_VPC
  route_table_id            = aws_route_table.first_rt.id
  destination_cidr_block    = aws_vpc.third_VPC.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.first_third_peering.id
}

resource "aws_route" "third_to_first_route" {
  provider                  = aws.third_VPC
  route_table_id            = aws_route_table.third_rt.id
  destination_cidr_block    = aws_vpc.first_VPC.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.first_third_peering.id
}

# -----------------------------------------------------------
# PEERING CONNECTION 2 <-> 3 (This was missing)
# -----------------------------------------------------------

# Requester (Initiated from Second)
resource "aws_vpc_peering_connection" "second_third_peering" {
  provider    = aws.second_VPC
  vpc_id      = aws_vpc.second_VPC.id
  peer_vpc_id = aws_vpc.third_VPC.id
  peer_region = var.third_region
  tags = {
    Name = "second-third-peering"
  }
}

# Accepter (Accepted by Third)
resource "aws_vpc_peering_connection_accepter" "second_third_accepter" {
  provider                  = aws.third_VPC
  vpc_peering_connection_id = aws_vpc_peering_connection.second_third_peering.id
  auto_accept               = true
  tags = {
    Name = "second-third-peering-accepter"
  }
}

resource "aws_route" "second_to_third_route" {
  provider                  = aws.second_VPC
  route_table_id            = aws_route_table.second_rt.id
  destination_cidr_block    = aws_vpc.third_VPC.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.second_third_peering.id
}

resource "aws_route" "third_to_second_route" {
  provider                  = aws.third_VPC
  route_table_id            = aws_route_table.third_rt.id
  destination_cidr_block    = aws_vpc.second_VPC.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.second_third_peering.id
}

# -----------------------------------------------------------
# INSTANCES
# -----------------------------------------------------------

resource "aws_instance" "first_instance" {
  provider               = aws.first_VPC
  ami                    = data.aws_ami.first_ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.first_VPC_subnet.id
  vpc_security_group_ids = [aws_security_group.first_sg.id]
  key_name               = var.first_key_name
  user_data              = local.first_user_data
  tags = {
    Name        = "First-VPC-Instance"
    environment = "Demo"
    region      = var.first_region
  }
  depends_on = [aws_vpc_peering_connection_accepter.first_second_accepter]
}

resource "aws_instance" "second_instance" {
  provider               = aws.second_VPC
  ami                    = data.aws_ami.second_ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.second_VPC_subnet.id
  vpc_security_group_ids = [aws_security_group.second_sg.id]
  key_name               = var.second_key_name
  user_data              = local.second_user_data
  tags = {
    Name        = "Second-VPC-Instance"
    environment = "Demo"
    region      = var.second_region
  }
  depends_on = [aws_vpc_peering_connection_accepter.first_second_accepter]
}

resource "aws_instance" "third_instance" {
  provider               = aws.third_VPC
  ami                    = data.aws_ami.third_ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.third_VPC_subnet.id
  vpc_security_group_ids = [aws_security_group.third_sg.id]
  key_name               = var.third_key_name
  user_data              = local.third_user_data
  tags = {
    Name        = "Third-VPC-Instance"
    environment = "Demo"
    region      = var.third_region
  }
  depends_on = [aws_vpc_peering_connection_accepter.first_third_accepter]
}