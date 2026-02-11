# Recap IAC

This article explores key concepts and tools in the Infrastructure as Code ecosystem to aid exam preparation and enhance IT infrastructure deployment.

In this article, we explore key concepts and tools in the Infrastructure as Code (IaC) ecosystem to help you prepare for your exam. IaC not only simplifies the deployment process but also ensures consistency and scalability in modern IT infrastructures.

We leverage a variety of tools such as Ansible, Terraform, Puppet, CloudFormation, Packer, SaltStack, Vagrant, Docker, and more. Although many of these tools can achieve similar outcomes, each one is optimized for specific tasks. Broadly, IaC tools are classified into three categories:

1.  **Configuration Management Tools**
2.  **Server Templating Tools**
3.  **Infrastructure Provisioning (Orchestration) Tools**

## 1. Configuration Management Tools

Configuration management tools like Ansible, Puppet, and SaltStack are designed to install and manage software on existing servers. Key features include:
*   **Designed to Install and Manage Software**: These tools automate software installation, configuration, and management.
*   **Maintains Standard Structure**: They enforce a standard structure and configuration across servers.
*   **Version Control**: Configurations are written in code and can be version-controlled.
*   **Idempotent**: The result of applying a configuration is the same, regardless of how many times it is applied.

## 2. Server Templating Tools

Server templating tools such as Docker, Packer, and Vagrant are used to create custom images of virtual machines or containers. These images are pre-installed with the required software and dependencies, eliminating the need for post-deployment software installation. Common examples include VM images from [osboxes.org](http://osboxes.org), custom [Amazon AMIs](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html), and Docker images from [Docker Hub](https://hub.docker.com/).

Server templating supports an immutable infrastructure model—making updates as simple as redeploying a new instance with an updated image rather than modifying a running system.

## 3. Infrastructure Provisioning (Orchestration) Tools

Provisioning tools, such as Terraform and CloudFormation, enable you to manage a variety of infrastructure components like virtual machines, databases, VPCs, subnets, security groups, and storage using declarative code. CloudFormation is ideal for AWS-only deployments, whereas Terraform offers a vendor-agnostic solution that supports multi-cloud or hybrid environments through numerous plugins.

> Although configuration management tools can provision infrastructure (for example, using Ansible’s EC2 module), this approach is less effective for managing larger infrastructures due to its procedural nature.

## Procedural vs. Declarative Approaches

### Ansible Example (Procedural)

Ansible employs a procedural approach in which every step must be explicitly defined. Consider the following playbook that provisions two EC2 instances:

```yaml
- name: Provision AWS Resources
  hosts: localhost
  tasks:
    - name: Provision EC2 instances using Ansible
      ec2:
        key_name: appserver
        instance_tags:
          Name: appserver
        instance_type: t2.micro
        image: ami-0d8ad3ab25e7abc51
        region: ca-central-1
        wait: yes
        count: 2
```

If you run the playbook again, Ansible will create two additional EC2 instances, resulting in a total of four. To maintain exactly two instances, you must include additional parameters to manage the desired state. The enhanced version for both provisioning and deletion is as follows:

```yaml
- name: Delete Instances
  ec2:
    state: absent
    instance_ids: '{{ ec2.instance_ids }}'
```

### Terraform Example (Declarative)

In contrast, Terraform uses a declarative approach where you specify the desired end state of your infrastructure. Consider the Terraform configuration below that ensures exactly two EC2 instances:

```hcl
resource "aws_instance" "app" {
  ami           = "ami-0d8ad3ab25e7abc51"
  instance_type = "t2.micro"
  count         = 2
  key_name      = "appserver"
  tags = {
    Name = "appserver"
  }
}
```

Running the following command applies the configuration:

```bash
> terraform apply
```

Terraform creates or maintains exactly two EC2 instances. On subsequent executions, Terraform will indicate that the current state matches the configuration:

```bash
> terraform apply
aws_instance.app[0]: Creation complete after 33s [id=i-014c93c14e12a6442]
aws_instance.app[1]: Creation complete after 33s [id=i-0fc7d85da32d24c63]
Terraform has compared your real infrastructure against your configuration and found no changes.
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

If no drift is detected, the output will confirm that the infrastructure is up-to-date.

Terraform maintains the state of each provisioned resource in a state file, which it uses to detect deviations between your desired configuration and the actual infrastructure. This powerful state management enables resource teardown using:

```bash
> terraform destroy
```

## Choosing the Right IaC Tool

There is no one-size-fits-all solution when it comes to selecting an IaC tool. For deployments exclusive to AWS, CloudFormation offers simplicity and direct integration. However, for multi-cloud or hybrid environments, Terraform’s vendor-agnostic design makes it a versatile choice.

> Maximize efficiency by leveraging the strengths of each IaC tool: use Terraform for resource provisioning and a configuration management tool like Ansible or Puppet for software management.

## Additional Resources

For more in-depth information on IaC tools, refer to the following documentation:
*   [Kubernetes Documentation](https://kubernetes.io/docs/home/)
*   [Docker Hub](https://hub.docker.com/)
*   [Terraform Registry](https://registry.terraform.io/)

Happy exploring!
