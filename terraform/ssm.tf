resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.project_name}/db_password"
  description = "DB password for ${var.project_name}"
  type        = "SecureString"
  value       = var.db_password
  overwrite   = true
  tags = {
    project = var.project_name
  }
}

data "aws_ssm_parameter" "db_password" {
  name = aws_ssm_parameter.db_password.name
}

