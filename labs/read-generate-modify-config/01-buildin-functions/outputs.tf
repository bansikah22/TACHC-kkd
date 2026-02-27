# The upper function converts a string to uppercase.
output "pet_name_uppercase" {
  value = upper(random_pet.my-pet.id)
}

# The join function concatenates a list of strings with a given separator.
output "server_names_joined" {
  value = join(", ", var.server_names)
}

# The element function retrieves a single element from a list.
output "first_server_name" {
  value = element(var.server_names, 0)
}

# The [*] splat expression returns all elements of a list.
output "all_server_names" {
  value = var.server_names[*]
}

# The lookup function retrieves the value of a single element from a map, given its key.
# If the given key does not exist, a default value is returned.
output "lookup_server_name" {
    value = lookup(var.server_names_map, "server1", "default-server")
}

# The index function finds the index of a given value in a list.
output "server_index" {
  value = index(var.server_names, "server2")
}