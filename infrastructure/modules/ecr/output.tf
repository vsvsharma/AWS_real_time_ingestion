output "repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.extraction_ecr_repo.repository_url
}
output "image_uri" {
  description = "Image URI"
  value       = "${aws_ecr_repository.extraction_ecr_repo.repository_url}:latest"
}
