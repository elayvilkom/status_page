resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "elay-noa-redis-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet1.id]

  tags = {
    Name  = "redis-subnet-group"
    owner = "elayvilkom"
  }
}

resource "aws_security_group" "redis_sg" {
  name   = "elay-noa-redis-security-group"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "elay-noa-redis-cluster"
  engine               = "redis"
  engine_version       = "6.x"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [aws_security_group.redis_sg.id]

  tags = {
    Name  = "elay-noa-redis"
    owner = "elayvilkom"
  }
}