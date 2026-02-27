# The "random_pet" resource generates a random pet name.
# This is useful for creating unique resource names.
resource "random_pet" "my-pet" {
  length    = "2"
  separator = "-"
}

# The "local_file" resource creates a file on the local filesystem.
# The filename is using string interpolation syntax "${...}" to embed the value of an expression into a string.
# In this case, it's embedding the ID of the "random_pet" resource.
resource "local_file" "pet" {
  filename = "${random_pet.my-pet.id}.txt"
  content  = "i love pets"
}

# This "local_file" resource uses the "for_each" meta-argument to create multiple files
# based on the "server_names" variable. "each.key" and "each.value" refer to the key and value
# of the current item in the iteration.
resource "local_file" "pet_for_each" {
  for_each = toset(var.server_names)
  filename = "servers/${each.key}.txt"
  content  = "server name is ${each.value}"
}

# This "local_file" resource uses the "count" meta-argument to create multiple files
# based on the length of the "server_names" variable. "count.index" refers to the index
# of the current item in the iteration.
resource "local_file" "pet_count" {
  count    = length(var.server_names)
  filename = "servers/server-${count.index}.txt"
  content  = "server name is ${var.server_names[count.index]}"
}
