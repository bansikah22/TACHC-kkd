# Dynamic Blocks and Splat Expressions in Terraform

This guide explores using dynamic blocks and splat expressions to create multiple resource instances efficiently and maintain cleaner code.

**Note:** The examples in this lab use the `aws_security_group` resource for demonstration purposes. To run `terraform apply`, you would need a valid AWS account and a pre-existing VPC. However, you can still run `terraform init` and `terraform plan` to see how Terraform would behave without actually creating resources.

## Dynamic Blocks

A dynamic block allows you to dynamically construct repeatable nested blocks inside a resource or other construct. This is useful when you need to create multiple instances of a nested block based on a variable or a complex data structure.

In our `main.tf`, we use a dynamic `ingress` block to create multiple ingress rules for an `aws_security_group`:

```hcl
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
```

In this configuration, the `dynamic "ingress"` block iterates over the `ingress_ports` variable and creates an `ingress` block for each port in the list. The `content` block defines the arguments for each `ingress` block.

## Splat Expressions

Splat expressions provide a convenient way to extract a list of attribute values from a list of resources or a complex data structure.

In our `main.tf`, we use a splat expression to get a list of all the `to_port` values from the dynamically generated `ingress` rules:

```hcl
output "to_ports" {
  value = aws_security_group.backend-sg.ingress[*].to_port
}
```

The `aws_security_group.backend-sg.ingress[*].to_port` expression will produce a list of all the `to_port` values from the `ingress` blocks of the `aws_security_group.backend-sg` resource.
