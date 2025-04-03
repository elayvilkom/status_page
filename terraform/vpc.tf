# יצירת VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "elay-noa-vpc", owner = "elayvilkom", "kubernetes.io/cluster/elay-noa-k8s-cluster" = "owned"  }
}

# יצירת Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = { Name = "elay-noa-igw", owner = "elayvilkom" }
}

# יצירת תתי-רשתות
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "elay-noa-subnet-pub1", owner = "elayvilkom" , "kubernetes.io/role/elb" = 1}
}
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "elay-noa-subnet-pub2", owner = "elayvilkom" , "kubernetes.io/role/elb" = 1}
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "elay-noa-subnet-private1", owner = "elayvilkom","kubernetes.io/role/internal-elb" = 1 }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "elay-noa-subnet-private2", owner = "elayvilkom" , "kubernetes.io/role/internal-elb" = 1}
}

# יצירת NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "my_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = { Name = "elay-noa-nat", owner = "elayvilkom" }
}

# יצירת Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = { Name = "elay-noa-PublicRT", owner = "elayvilkom" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_assocc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id =aws_nat_gateway.my_nat.id
  }
  tags = { Name = "elay-noa-privateRT", owner = "elayvilkom" }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "private_assocs" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}