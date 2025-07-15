variable "AWS_REGION" {
  type    = string
  default = "us-east-1"
}

variable "AWS_ACCESS_KEY_ID" {
  type = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = string
}

variable "AWS_SESSION_TOKEN" {
  type = string
}

variable "BRANCH_NAME" {
  type    = string
  default = "dev"
}

variable "DB_KIND" {
  type        = string
  description = "Tipo de base de datos"
}

variable "JDBC_URL" {
  type        = string
  description = "JDBC URL de la base de datos"
}

variable "DB_USERNAME" {
  type        = string
  description = "Usuario de la base de datos"
}

variable "DB_PASSWORD" {
  type        = string
  description = "Contraseña de la base de datos"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID para los recursos"
}

variable "subnets" {
  type        = list(string)
  description = "Lista de subnets para los recursos"
}

variable "ami_id" {
  type    = string
  default = "ami-020cba7c55df1f615"
}
