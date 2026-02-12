# readom pet name
resource "random_pet" "cat" {
    length = 2
    separator = "-"
}

# define local values
locals {
    pet_name = "my-pet"
    env      = "production"

    // complex reusable expression
    full_name = "${local.pet_name}-${local.env}-${random_pet.cat.id}"

    // a map of common tags
    common_tags = {
        "Environment" = local.env
        "Project"     = local.pet_name
    }
}

// use local value
resource "local_file" "favorite_pet"{
    filename = "${local.full_name}.txt"
    content = "My favorite pet is ${local.full_name}"
}