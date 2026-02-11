# Recap Using Terraform Providers

This article recaps Terraform providers and illustrates their use for provisioning resources across various platforms.

In this article, we recap Terraform providers and illustrate how to use them to provision resources across various platforms.

Terraform follows a plugin-based architecture that supports hundreds of platforms, including AWS, GCP, Azure, and more. The first command you"ll run with a valid configuration is the Terraform init command. This command installs the necessary plugins for the providers specified in your configuration.

> Running `terraform init` is safe and can be executed multiple times without affecting your deployed infrastructure.

```bash
$ terraform init
```

Terraform providers are distributed separately from Terraform itself and are available for download on the Terraform Registry. The registry categorizes providers into three types:

1.  **Official Providers**: Owned and maintained by HashiCorp. These include major cloud providers like AWS, GCP, and Azure. Official providers feature a distinct badge in the Terraform Registry.
2.  **Partner Providers**: Maintained by third-party technology companies but reviewed and tested by HashiCorp. They are identified by a checkmark badge in the registry.
3.  **Community Providers**: Published and maintained by individual contributors.

## Understanding Terraform Init Output

When running `terraform init`, you may see output similar to the following:

```bash
$ terraform init
Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/local...
- Installing hashicorp/local v2.0.0...
- Installed hashicorp/local v2.0.0 (signed by HashiCorp)

The following providers do not have any version constraints in configuration,
so the latest version was installed.

* hashicorp/local: version = "~> 2.0.0"

Terraform has been successfully initialized!
```

In this output, you can observe that the plugin for the HashiCorp Local provider (version 2.0.0) has been installed in your working directory. The plugins are downloaded into a hidden folder named `.terraform/plugins` located in the directory containing your configuration files.

> For production environments, always add version constraints in your configuration to avoid unexpected breaking changes from automatic upgrades.

## Provider Naming Convention

Terraform provider names include the hostname and namespace. For example, in the case of the local provider, the namespace is “hashicorp”, and the hostname is `registry.terraform.io`. Common examples include AWS, Azure, and Google Cloud.

By default, if the hostname is omitted, it defaults to `registry.terraform.io`. Therefore, the source address for the local provider can be specified as either:

*   `registry.terraform.io/hashicorp/local`
*   or simply `hashicorp/local`

> To prevent automatic upgrades to new major versions that may contain breaking changes, we recommend adding a version constraints block to the `required_providers` block in your configuration, with the constraint `~>`.

```hcl
terraform {
  required_providers {
    local = {
      source  = "registry.terraform.io/hashicorp/local"
      version = "~> 2.0.0"
    }
  }
}
```

**Watch Video**
[Learn more >](https://kodekloud.com/courses/terraform-associate-certification-hashicorp-certified/)
