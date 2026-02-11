# Terraform State

This article reviews Terraform state, its purpose, and best practices for managing it effectively.

In this lesson, we’ll review Terraform state, its purpose, and best practices for managing it. Terraform state is a JSON file that records your infrastructure’s current configuration and serves as a single source of truth for Terraform operations like plan and apply.

When you create a resource for the first time by running the Terraform apply command, Terraform generates a state file named terraform.tfstate in the same directory as your configuration files. Additionally, a backup file called terraform.tfstate.backup is created.

## Initial Resource Creation

Consider the following Terraform configuration:

```hcl
# main.tf
provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "cerberus" {
  ami           = var.ami
  instance_type = var.instance_type
}

# variables.tf
variable "ami" {
  default = "ami-06178cf087598769c"
}

variable "instance_type" {
  default = "m5.large"
}
```

When you run the apply command:

```bash
$ terraform apply
aws_instance.cerberus: Creating...
aws_instance.cerberus: Still creating... [10s elapsed]
aws_instance.cerberus: Creation complete after 12s [id=i-9d394a982f158e8a7]
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Terraform creates a `terraform.tfstate` file with content similar to this:

```json
{
    "version": 4,
    "terraform_version": "0.13.3",
    "serial": 2,
    "lineage": "ccd95cf0-9966-549b-c7d1-1d2683b3119b",
    "outputs": {},
    "resources": [
        {
            "mode": "managed",
            "type": "aws_instance",
            "name": "cerberus",
            "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
            "instances": [
                {
                    "schema_version": 1,
                    "attributes": {
                        "ami": "ami-06178cf087598769c",
                        "arn": "arn:aws:ec2:eu-west-2:instance/i-9d394a982f158e887",
                        "associate_public_ip_address": true,
                        "availability_zone": "eu-west-2a",
                        "disable_api_termination": false,
                        "ebs_block_device": []
                    }
                }
            ]
        }
    ]
}
```

This state file holds vital information such as resource IDs, provider details, and all resource attributes that Terraform uses to manage your infrastructure.

## Refreshing State with Terraform Plan

Before generating an execution plan, Terraform refreshes the state by comparing it with the actual state of your external resources. For example, if you run `terraform plan` after manually stopping the EC2 instance, Terraform will detect the discrepancy and update the state file accordingly.

```bash
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
aws_instance.cerberus: Refreshing state... [id=i-9d394a982f158e8a7]
No changes. Infrastructure is up-to-date.
```

If no differences are detected between your configuration and the real-world resources, Terraform indicates that no changes are needed. The apply command also performs a state refresh before proceeding with any updates.

In certain cases, you might want to skip refreshing the state. This can be done using the `-refresh=false` option:

```bash
$ terraform apply -refresh=false
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

> Disabling the state refresh is generally not recommended as it may introduce inconsistencies if resources have been manually modified. Use this option with caution, especially in large environments.

## Tracking Configuration Changes with the State File

The state file also tracks changes in your configuration. If you modify a variable, Terraform will detect the change and plan to update the resource.

### Original Variable Definitions

```hcl
variable "ami" {
  default = "ami-06178cf087598769c"
}

variable "instance_type" {
  default = "m5.large"
}
```

And a sample snippet from the terraform.tfstate file:

```json
{
    "version": 4,
    "terraform_version": "0.13.3",
    "serial": 1,
    ...
    "resources": [
        {
            ...
            "instances": [
                {
                    "schema_version": 1,
                    "attributes": {
                        "ami": "ami-06178cf087598769c",
                        "instance_type": "m5.large",
                        ...
                    }
                }
            ]
        }
    ]
}
```

### After Modifying the Configuration

If you change the `instance_type` to `t3.micro`:

```hcl
variable "instance_type" {
  default = "t3.micro"
}
```

Terraform’s execution plan will mark the resource for recreation due to the change in instance type.

## Managing Resource Dependencies

Terraform also manages inter-resource dependencies using the state file. Consider a configuration where a web instance depends on a DB instance:

```hcl
resource "aws_instance" "db" {
  ami           = var.ami
  instance_type = var.instance_type
}

resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  depends_on = [aws_instance.db]
}
```

The state file captures this dependency explicitly:

```json
{
    "mode": "managed",
    "type": "aws_instance",
    "name": "web",
    "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
    "instances": [
        {
            "schema_version": 1,
            "attributes": {
                "ami": "ami-06178cf087598769c",
                "arn": "arn:aws:ec2:eu-west-2:instance/i-33b55018bd1a8d8ca",
                ...
            },
            "dependencies": [
                "aws_instance.db"
            ]
        }
    ]
}
```

During provisioning, Terraform creates the DB instance first, followed by the web instance. Conversely, when destroying resources, Terraform will remove the web instance before deleting the DB instance.

## Security and Remote State Management

> The state file contains sensitive information, including configuration variables and resource attributes like SSH keys or initial passwords. Store your state file securely in remote backends (e.g., Amazon S3 or Terraform Cloud) and never commit it to version control systems.

For illustration, here is a snippet showing sensitive data in a state file:

```json
{
    "mode": "managed",
    "type": "aws_instance",
    "name": "web",
    "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
    "instances": [
        {
            "schema_version": 1,
            "attributes": {
                "ami": "ami-0a634ae95e11c6f91",
                ...
                "primary_network_interface_id": "eni-0ccd57b1597e633e0",
                "private_dns": "ip-172-31-7-21.us-west-2.compute.internal",
                "private_ip": "172.31.7.21",
                "public_dns": "ec2-54-71-34-19.us-west-2.compute.amazonaws.com",
                "public_ip": "54.71.34.19",
                "root_block_device": [
                    {
                        "delete_on_termination": true,
                        "device_name": "/dev/sda1",
                        "encrypted": false,
                        "iops": 100,
                        "kms_key_id": "vol-070720a3636979c22"
                    }
                ],
                ...
            }
        }
    ]
}
```

Remember, proper management of your Terraform state is key to maintaining the integrity and security of your infrastructure. For more detailed information and advanced state management practices, refer to the [Terraform documentation](https://www.terraform.io/docs/language/state/index.html).

## Summary

| Topic | Description | Example Command/Resource |
| :--- | :--- | :--- |
| Terraform State File | Tracks infrastructure, resources, and metadata in a JSON format | `terraform.tfstate`, `terraform.tfstate.backup` |
| Refreshing Terraform State | Ensures state matches external resources before planning and applying | `terraform plan`, `terraform apply` |
| Resource Dependencies | Records dependencies to manage correct resource creation and destruction order | `depends_on` attribute in resource configuration |
| Secure State Management | Store state securely using backends like Amazon S3 or Terraform Cloud to prevent sensitive data exposure | `terraform backend` |

**Watch Video**
[Learn more >](https://kodekloud.com/courses/terraform-associate-certification-hashicorp-certified/)
