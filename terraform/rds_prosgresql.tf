
# יצירת DB Subnet Group עבור RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "elay-noa-rds-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet1.id]
  tags = { Name  = "rds-subnet-group", owner = "elayvilkom" }
}
resource "aws_db_instance" "rds_postgres" {
  identifier            = "my-postgres-db"
  allocated_storage     = 20
  storage_type          = "gp2"
  engine               = "postgres"
  engine_version       = "14.17"
  instance_class       = "db.t3.micro"
  username             = "mamram"
  password             = "SuperSecurePassword123"
  publicly_accessible  = false
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  tags = { Name = "elay_db", owner = "elayvilkom" }
}

resource "aws_security_group" "rds_sg" {
  name   = "elay-noa-rds-security-group"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

