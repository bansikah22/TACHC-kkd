resource "aws_security_group" "backend-sg" {
  name   = "backend-sg"
  vpc_id = "vpc-12345678" # Dummy VPC ID

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

output "to_ports" {
  value = aws_security_group.backend-sg.ingress[*].to_port
}
