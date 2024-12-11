/*
creating ecr repo to store the docker image of the extraction code file
*/


resource "aws_ecr_repository" "extraction_ecr_repo" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE" # Options: MUTABLE or IMMUTABLE
  image_scanning_configuration {
    scan_on_push = true # Enable image scan on push
  }
}

