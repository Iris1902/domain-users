variable "name" {
  description = "Nombre del microservicio"
  type        = string
}

variable "image_user_create" {
  description = "Imagen Docker para user-create"
  type        = string
}

variable "port_user_create" {
  description = "Puerto para user-create"
  type        = number
}

variable "image_user_read" {
  description = "Imagen Docker para user-read"
  type        = string
}

variable "port_user_read" {
  description = "Puerto para user-read"
  type        = number
}

variable "image_user_update" {
  description = "Imagen Docker para user-update"
  type        = string
}

variable "port_user_update" {
  description = "Puerto para user-update"
  type        = number
}

variable "image_user_delete" {
  description = "Imagen Docker para user-delete"
  type        = string
}

variable "port_user_delete" {
  description = "Puerto para user-delete"
  type        = number
}

variable "branch" {
  description = "Tag de Docker"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID para los recursos"
}

variable "subnet1" {
  type        = string
  description = "ID de la primera subnet"
}

variable "subnet2" {
  type        = string
  description = "ID de la segunda subnet"
}

variable "ami_id" {
  type    = string
  default = "ami-020cba7c55df1f615"
}

variable "db_kind" {
  description = "Tipo de base de datos"
  type        = string
}

variable "jdbc_url" {
  description = "JDBC URL de la base de datos"
  type        = string
}

variable "db_username" {
  description = "Usuario de la base de datos"
  type        = string
}

variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
}
