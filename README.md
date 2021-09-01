# Terraform Cloud/Enterprise YAML Variables

Terraform module which makes it possible to set and use workspace variables from a file stored in a repository.

Even though this module supports sensitive variables it's not recommended to save sensitive variables in a file stored in a repository.

## Authentication

This module requires a Terraform Cloud/Enterprise API token in order to manage workspace variables.

There are several ways to provide the required token for the provider:

* Set the `token` argument in the provider configuration. You can set the `token` argument in the provider configuration. Use an input variable for the token.
* Set the `TFE_TOKEN` environment variable: The provider can read the `TFE_TOKEN` environment variable and the token stored there to authenticate.

When configuring the input variable for either of these options, mark them as sensitive.

## Usage example

This module reads all arguments that `tfe_variable` supports from the YAML file. See the documentation for more information about [`tfe_variable`][tfe_variable] resource arguments. Only expection to `tfe_variable` resource arguments is that `category` is by default set to `terraform`.

### `my-workspace-name.yaml`

```yaml
- key: count
  value: 3
- key: instance_type
  value: t2.micro
```

### `main.tf`

```hcl
module "yaml" {
  source  = "0x022b/yaml-variables/tfe"
  version = "~> 1.0"

  organization = "my-organization-name"
  workspace    = "my-workspace-name"
}

resource "aws_instance" "cluster" {
  count = module.yaml.variables.count

  instance_type = module.yaml.variables.instance_type
  # ...
}
```

## Inputs

Name         | Description
-------------|-------------
organization | Name of the organization.
workspace    | Name of the workspace.
dirname      | Filesystem path to a directory containing variable files.

## Outputs

Name      | Description
----------|-------------
variables | YAML file variables as a key-value map.

## License

MIT

[tfe_variable]: https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/variable
