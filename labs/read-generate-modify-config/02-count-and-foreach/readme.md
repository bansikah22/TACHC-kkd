# Count and for_each in Terraform

This guide explores using Terraform's `count` and `for_each` meta-arguments to create multiple resource instances efficiently.

## Using Count

The `count` meta-argument allows you to create multiple copies of a resource. In the `main.tf` file, we are creating multiple `local_file` resources by setting `count` to the length of the `webservers_list` variable.

```hcl
resource "local_file" "count_example" {
  count    = length(var.webservers_list)
  filename = "count-example-${var.webservers_list[count.index]}.txt"
  content  = "This file was created using count."
}
```

After running `terraform apply`, Terraform records these files in the state file as a list. This means that each resource is identified by its index, for example:

* `local_file.count_example[0]`
* `local_file.count_example[1]`
* `local_file.count_example[2]`

### Potential Drawback of Using Count

One important limitation of the `count` meta-argument is that it organizes resources based on list indices. If the order of the elements changes or an element is removed, Terraform may update the wrong resource or destroy the unintended instance.

## Using For_Each

The `for_each` meta-argument offers an alternative approach by creating a resource for each element in a set or map. Unlike `count`, `for_each` stores resources in a map keyed by each element’s value, eliminating issues caused by index reordering.

In the `main.tf` file, we are using `for_each` to loop through the `webservers_set` variable:

```hcl
resource "local_file" "foreach_example" {
  for_each = var.webservers_set
  filename = "foreach-example-${each.key}.txt"
  content  = "This file was created using for_each."
}
```

Key advantages of using `for_each`:

* The `webservers_set` variable is defined as a set to ensure unique keys.
* Each resource is identified by its key, such as `local_file.foreach_example["web1"]`.
* Removing an element (like `"web1"`) only destroys that specific resource without affecting the others.

After applying this configuration, running `terraform state list` displays resources as:

```bash
$ terraform state list
local_file.foreach_example["web1"]
local_file.foreach_example["web2"]
local_file.foreach_example["web3"]
```

This predictable mapping means that modifying the set—such as removing `"web1"`—only affects the corresponding resource.
