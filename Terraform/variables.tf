variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_region" {}

variable "server_port" {
  description = "The Port the server will use for HTTP requests"
  default     = 8080
}
