resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = data.aws_subnet_ids.default.ids
  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "default" {
  identifier              = "${var.project_name}-db"
  allocated_storage       = var.db_allocated_storage
  engine                  = var.db_engine
  engine_version          = var.db_engine == "mysql" ? "8.0" : "13.4"
  instance_class          = "db.t3.micro"
  name                    = "ecomdb"
  username                = var.db_username
  password                = data.aws_ssm_parameter.db_password.value
  publicly_accessible     = false
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.default.name
  backup_retention_period = 7
  tags = {
    Name = "${var.project_name}-rds"
  }
}

