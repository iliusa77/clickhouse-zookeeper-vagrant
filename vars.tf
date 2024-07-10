variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-2"
}

variable "env" {
  default = "sandbox"
}

variable "ec2_availability_zones" {
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "ec2_instance_type" {
  default = "t2.small"
}

variable "ec2_ebs_size" {
  default = "50"
}

variable "ec2_ebs_type" {
  default = "gp3"
}

variable "ec2_ami" {
  default = "ami-0fe310dde2a8fdc5c" #Amazon Linux 2023 AMI 2023.5.20240701.0 x86_64 HVM kernel-6.1
}

variable "ec2_ssh_public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC03Ri3tLajc/INuzsipG8gFY7i1gV4bFGKdyYY297cQZZf4YpHy4X4XVfCnlcrm3zlFjV+JYPaF4hEtY0tWYEFIEfvsNB4D67nCSF4yJgdPLFoO13HOnPf6zKD1eC4hdBjnAhcm2SBYX+tXRba0neiPh1X0nQmwd8mqIsY+p0g0b1KpBbkz0ETTzBp0wCX/C3a42R0KBpjJmTDqN9o6zOzknXe6np+7/wf89PqyaKivQHNijWz4G1s+IvQm7B/cDuwiPbVA6gl4a7hFDkBdZSAtppyPcD557kwPFy9qPdMatdtsQ77K5MEpTsEluuxaZPUEV0Ak3pRkv34O6oqzJUM8el+PICSTXkBYVPXkZo675HK8UQaFOUeDFYlBUYw3RbBzLPn2r9sS9axDrptKoXn6bDMVGY6K/mN5KFIF59KqDhXGn8aHGSkXAEKG3VeLQVqNuGwOYcy/fU0yU3iUifzVXlIqvPmXPF63hu7yHd6wj2kXFS9OHjXI49JBkJgegj7dMKRDH7vgZbfcmSSKKMo7Fl2M34qnjBOmFa6jBwBIiOMrbefCA98pGXtbGZ7g5yWrQYmrz3S1/Y4pWhXfGFnCDxXLTmNpoTOqcue8h8S/tx/jQUlQh5uX1g5IOUjy5INMJtHLsmVCz64WmpLN6J1h1DvHoBV2+2qTQUqPJdjcw=="
}

variable "cidrsubnet" {
  default     = "10.0.7.0/24"
}
