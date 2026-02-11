# Count and for each

This guide explores using Terraform’s `count` and `for_each` meta-arguments to create multiple resource instances efficiently.

In this guide, we’ll explore how to use Terraform’s meta-arguments—`count` and `for_each`—to efficiently create multiple instances of a resource using the same configuration block. Understanding these options will help you manage resource deployments more dynamically and reliably.

## Using Count

The `count` meta-argument allows you to create multiple copies of a resource. In the example below, we launch three EC2 instances by setting `count = 3`:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  count         = 3
}

variable "ami" {
  default = "ami-06178cf087598769c"
}

variable "instance_type" {
  default = "m5.large"
}
```

After running `terraform apply`, Terraform records these instances in the state file as a list. This means that each resource is identified by its index, for example:

- `aws_instance.web[0]`
- `aws_instance.web[1]`
- `aws_instance.web[2]`

### Dynamically Setting Count Using a List variable

You can dynamically set the `count` by using the `length` of a list variable. This approach allows you to create a variable number of resources based on the number of elements in a list.

In this example, we define a `webservers` variable as a list of strings and use its length to determine how many EC2 instances to create. We also use the `count.index` to assign a name to each instance:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  count         = length(var.webservers)
  tags = {
    Name = var.webservers[count.index]
  }
}

variable "ami" {
  default = "ami-06178cf087598769c"
}

variable "instance_type" {
  default = "m5.large"
}

variable "webservers" {
  type    = list(string)
  default = ["web1", "web2", "web3"]
}
```

This configuration will create three EC2 instances, with each instance tagged according to its corresponding name.

> Using a dynamic list makes your Terraform configuration more flexible and easier to maintain when scaling resources.

## Potential Drawback of Using Count

One important limitation of the `count` meta-argument is that it organizes resources based on list indices. If the order of the elements changes or an element is removed, Terraform may update the wrong resource or destroy the unintended instance.

For example, consider the updated configuration when `"web1"` is removed from the list:

```hcl
# main.tf
resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  count         = length(var.webservers)
  tags = {
    Name = var.webservers[count.index]
  }
}

# variables.tf
variable "ami" {
  default = "ami-06178cf087598769c"
}

variable "instance_type" {
  default = "m5.large"
}

variable "webservers" {
  type    = list(string)
  default = ["web2", "web3"]
}
```

Running `terraform plan` may generate an execution plan like this:

```
Terraform will perform the following actions:

  # aws_instance.web[0] will be updated in-place
  ~ resource "aws_instance" "web" {
        id = "i-0a1b2c3d4e5f6g7h8"
      ~ tags = {
          ~ "Name" = "web1" -> "web2"
        }
    }

  # aws_instance.web[1] will be updated in-place
  ~ resource "aws_instance" "web" {
        id = "i-0a1b2c3d4e5f6g7h9"
      ~ tags = {
          ~ "Name" = "web2" -> "web3"
        }
    }

  # aws_instance.web[2] will be destroyed
  - resource "aws_instance" "web" {
      ...
    }

Plan: 0 to add, 2 to change, 1 to destroy.
```

## Using For_Each

The `for_each` meta-argument offers an alternative approach by creating a resource for each element in a set or map. Unlike `count`, `for_each` stores resources in a map keyed by each element’s value, eliminating issues caused by index reordering.

Consider the following configuration that uses `for_each` to loop through the `webservers` variable:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami
  instance_type = var.instance_type
  for_each      = var.webservers
  tags = {
    Name = each.value
  }
}

variable "ami" {
  default = "ami-06178cf087598769c"
}

variable "instance_type" {
  default = "m5.large"
}

variable "webservers" {
  type    = set(string)
  default = ["web1", "web2", "web3"]
}
```

Key advantages of using `for_each`:

- The `webservers` variable is defined as a set (or map) to ensure unique keys.
- Each resource is identified by its key, such as `aws_instance.web["web1"]`.
- Removing an element (like `"web1"`) only destroys that specific resource without affecting the others.

After applying this configuration, running `terraform state list` displays resources as:

```bash
$ terraform state list
aws_instance.web["web1"]
aws_instance.web["web2"]
aws_instance.web["web3"]
```

This predictable mapping means that modifying the set—such as removing `"web1"`—only affects the corresponding resource.

## Conclusion

In this article, we explored two strategies for provisioning multiple instances in Terraform: using `count` and `for_each`. While `count` is straightforward, it can introduce complications when handling dynamic lists due to index-based identification. In contrast, `for_each` facilitates more predictable resource management by leveraging set or map keys.

By understanding these distinctions, you can choose the most appropriate approach for your Terraform configurations and avoid unintended resource modifications. Stay tuned for our next article, where we’ll dive deeper into advanced Terraform concepts and best practices.

For more detailed Terraform documentation and best practices, visit the [Terraform Registry](https://registry.terraform.io/) or [HashiCorp’s documentation](https://www.terraform.io/docs/language/meta-arguments/for_each).
