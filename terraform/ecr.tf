
resource "aws_ecr_repository" "ecr_repo" {
  name                 = "elay-noa-ecr-repo"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  
  }
  tags = { 
    owner = "elayvilkom"
  }
}
