resource "aws_vpc" "agevegacom_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-vpc"
    },
  )
}

# Create 3 public subnets in different AZs
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.agevegacom_vpc.id
  cidr_block              = var.public_subnets[0]
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-subnet-public1-${var.availability_zones[0]}"
    },
  )
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.agevegacom_vpc.id
  cidr_block              = var.public_subnets[1]
  availability_zone       = var.availability_zones[1]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-subnet-public2-${var.availability_zones[1]}"
    },
  )
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.agevegacom_vpc.id
  cidr_block              = var.public_subnets[2]
  availability_zone       = var.availability_zones[2]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-subnet-public3-${var.availability_zones[2]}"
    },
  )
}

# Create 3 private subnets in different AZs
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.agevegacom_vpc.id
  cidr_block        = var.private_subnets[0]
  availability_zone = var.availability_zones[0]

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-subnet-private1-${var.availability_zones[0]}"
    },
  )
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.agevegacom_vpc.id
  cidr_block        = var.private_subnets[1]
  availability_zone = var.availability_zones[1]

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-subnet-private2-${var.availability_zones[1]}"
    },
  )
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.agevegacom_vpc.id
  cidr_block        = var.private_subnets[2]
  availability_zone = var.availability_zones[2]

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-subnet-private3-${var.availability_zones[2]}"
    },
  )
}

# Create 3 database subnets in different AZs (no Internet access)
resource "aws_subnet" "db_subnet_1" {
  vpc_id            = aws_vpc.agevegacom_vpc.id
  cidr_block        = var.db_subnets[0]
  availability_zone = var.availability_zones[0]

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-subnet-db1-${var.availability_zones[0]}"
    },
  )
}

resource "aws_subnet" "db_subnet_2" {
  vpc_id            = aws_vpc.agevegacom_vpc.id
  cidr_block        = var.db_subnets[1]
  availability_zone = var.availability_zones[1]

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-subnet-db2-${var.availability_zones[1]}"
    },
  )
}

resource "aws_subnet" "db_subnet_3" {
  vpc_id            = aws_vpc.agevegacom_vpc.id
  cidr_block        = var.db_subnets[2]
  availability_zone = var.availability_zones[2]

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-subnet-db3-${var.availability_zones[2]}"
    },
  )
}

# Create an Internet Gateway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.agevegacom_vpc.id

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-igw"
    },
  )
}

# Create a route table for public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.agevegacom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-rtb-public"
    },
  )
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_3_association" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a route table for each private subnet
resource "aws_route_table" "private_route_table_1" {
  vpc_id = aws_vpc.agevegacom_vpc.id

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-rtb-private1-${var.availability_zones[0]}"
    },
  )
}

resource "aws_route_table" "private_route_table_2" {
  vpc_id = aws_vpc.agevegacom_vpc.id

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-rtb-private2-${var.availability_zones[1]}"
    },
  )
}

resource "aws_route_table" "private_route_table_3" {
  vpc_id = aws_vpc.agevegacom_vpc.id

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-rtb-private3-${var.availability_zones[2]}"
    },
  )
}

# Create a route table for each database subnet
resource "aws_route_table" "db_route_table_1" {
  vpc_id = aws_vpc.agevegacom_vpc.id

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-rtb-db1-${var.availability_zones[0]}"
    },
  )
}

resource "aws_route_table" "db_route_table_2" {
  vpc_id = aws_vpc.agevegacom_vpc.id

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-rtb-db2-${var.availability_zones[1]}"
    },
  )
}

resource "aws_route_table" "db_route_table_3" {
  vpc_id = aws_vpc.agevegacom_vpc.id

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.project_name}-rtb-db3-${var.availability_zones[2]}"
    },
  )
}

# Associate private subnets with their respective route tables

resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table_1.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table_2.id
}

resource "aws_route_table_association" "private_subnet_3_association" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private_route_table_3.id
}

# Associate database subnets with their dedicated route tables

resource "aws_route_table_association" "db_subnet_1_association" {
  subnet_id      = aws_subnet.db_subnet_1.id
  route_table_id = aws_route_table.db_route_table_1.id
}

resource "aws_route_table_association" "db_subnet_2_association" {
  subnet_id      = aws_subnet.db_subnet_2.id
  route_table_id = aws_route_table.db_route_table_2.id
}

resource "aws_route_table_association" "db_subnet_3_association" {
  subnet_id      = aws_subnet.db_subnet_3.id
  route_table_id = aws_route_table.db_route_table_3.id
}
