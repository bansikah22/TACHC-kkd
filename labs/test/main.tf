variable "project_name" {
  type    = string
  default = "storm"
}

variable "department" {
  type    = string
  default = "finance"
}

variable "ami" {
  default = "ami-06178cf087598769c"
}

variable "instance_type" {
  default = "m5.large"
}

variable "region" {
  default = "eu-west-2"
}


locals {
  # This combines your variables into one string
  instance_name = "${var.project_name}-${var.department}-server"
}

resource "aws_instance" "storm" {
  ami           = var.ami
  instance_type = var.instance_type # Changed from local.Name (which was causing an error)
  
  tags = {
    # 2. Reference the local here
    Name = local.instance_name
  }
}
