variable "access_key" {
  description = "aws access key"
  type        = string
}

variable "secret_key" {
  description = "aws secret key"
  type        = string
}

variable "public_key" {
  description = "aws instance public key"
  type        = string
}

variable "azs" {
  description = "aws availability zone"
  type        = list(string)
  default      = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

variable "certificate_arn" {
  description = "value"
  type        = string
}