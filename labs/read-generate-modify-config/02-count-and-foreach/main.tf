resource "local_file" "count_example" {
  count    = length(var.webservers_list)
  filename = "count-example-${var.webservers_list[count.index]}.txt"
  content  = "This file was created using count."
}

resource "local_file" "foreach_example" {
  for_each = var.webservers_set
  filename = "foreach-example-${each.key}.txt"
  content  = "This file was created using for_each."
}
