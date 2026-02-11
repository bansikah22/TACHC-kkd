# Terraform Modules

This article explains Terraform modules, their structure, usage, and benefits for organizing infrastructure as code.

Terraform modules are a powerful way to organize your infrastructure as code. In Terraform, any directory containing configuration files is considered a module. Each Terraform configuration must have one root module, which is the directory where you run your Terraform commands. In this guide, we’ll review how modules work and demonstrate how to use both local and registry modules.

## Understanding the Root Module

Consider a configuration directory called `aws-instance` inside your Terraform projects directory. This folder contains the configuration files `main.tf` and `variables.tf`, which define the resources for creating an AWS instance. Since Terraform commands are executed inside this folder, `aws-instance` serves as the root module for that configuration.

The `main.tf` file might include the following configuration:

```hcl
resource "aws_instance" "webserver" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key
}
```

And the `variables.tf` file could define variables like this:

```hcl
variable "ami" {
  type        = string
  default     = "ami-0edab43b6fa892279"
  description = "Ubuntu AMI for EC2 instance"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type for EC2"
}

variable "key_name" {
  type        = string
  default     = " "
  description = "Key pair for EC2 instance"
}
```

Terraform modules can also reference other modules, enabling you to package and reuse resource configurations efficiently. Suppose you wish to create a new development web server instance using the existing “aws-instance” module. Instead of duplicating the configuration, you can simply call the module from a new directory called “development.”

First, create the new directory:

```bash
$ mkdir /root/terraform-projects/development
```

Inside the “development” directory, create a configuration file with the following module block that references the local AWS instance module:

```hcl
module "dev-webserver" {
  source = "../aws-instance"
}
```

Since Terraform commands are executed from the “development” directory, it becomes the root module and the `aws-instance` directory is now considered a child module.

You can also use an absolute path for the source:

```hcl
module "dev-webserver" {
  source = "/root/terraform-projects/aws-instance"
}
```

> Using absolute paths can be effective in some scenarios, but it is generally recommended to use relative paths for portability.

## Leveraging the Terraform Registry

One of the key benefits of using modules is code reusability. In addition to local modules, you can also utilize modules hosted on the [Terraform Registry](https://registry.terraform.io/), which is a robust repository for both provider plugins and community or official modules. For example, instead of writing a security group configuration from scratch, you might search for a suitable module in the Registry.

Below is an example search result for security group modules:

Modules found in the Registry typically come with detailed documentation, version information, and usage instructions with examples. They might also offer sub-modules for specific use cases, such as creating inbound HTTP or HTTPS security rules.

To use a module from the Registry, you need to specify its source and version specifications. For instance:

```hcl
module "security-group" {
  source  = "terraform-aws-modules/security-group"
  version = "3.16.0"
  # Insert the required variables here
}
```

If you need a sub-module specifically for SSH access, requiring additional arguments like a security group name, VPC ID, and ingress CIDR blocks, your configuration might look like this:

```hcl
module "security-group_ssh" {
  source  = "terraform-aws-modules/security-group/aws/modules/ssh"
  version = "3.16.0"
  vpc_id = "vpc-7d8d215"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  name = "ssh"
}
```

Download necessary provider plugins and modules by running:

```bash
$ terraform init
Downloading terraform-aws-modules/security-group/aws 3.16.0 for security-group_ssh...
- security-group_ssh in .terraform/modules/security-group_ssh/modules/ssh
```

2.  **Plan and Apply**:
    Validate the configuration with `terraform plan` and create the resources using `terraform apply`.

> Remember that running `terraform init`, `terraform plan`, and `terraform apply` in the directory where your root module is located is crucial for successful deployment.

## Benefits of Using Modules

Modules in Terraform offer numerous benefits for managing your infrastructure code:

| Benefit | Description |
| :--- | :--- |
| **Code Reusability** | Package and reuse configurations to avoid duplication. |
| **Improved Readability** | Maintain shorter and more understandable root modules. |
| **Reduced Risk of Human Error**| Use tested and validated modules to minimize errors. |
| **Configuration Locking** | Restrict specific variables in the root module to enforce standard parameters. |

These benefits emphasize why modules are a vital tool for creating consistent and standardized cloud environments.

## Next Steps

In the next lesson, we will dive deeper into advanced module usage, exploring techniques for module parameterization and dependency management. For further learning, consider visiting the [Terraform Documentation](https://www.terraform.io/docs/language/modules/index.html) or exploring additional modules on the [Terraform Registry](https://registry.terraform.io/).

Happy coding with Terraform!
