[Use official website](...)

```tf
resource "local_file" "pet" {
    filename = "/root/pets.txt"
    content = "We love pets!"
}
```
Explain various  parts
- Block name
- local=provider, can be aws, azure...
- file=resource
- Resource Type= local_file
- Resource name= pet
- filename, content = arguments

**Resource** : an object that terraform manages, it could be ec2, s3 bucket and so ... we have 100s

## Terraform flow
- terraform init, understand what it does
- terraform plan, understand what it does 
- terraform apply, ....
- terraform apply --auto-approve
- terraform show
