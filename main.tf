terraform {
  required_providers {
    tfe = {
      source = "hashicorp/tfe"
    }
  }
}

variable "dirname" {
  default     = "."
  description = "Filesystem path to a directory containing variable files."
  type        = string
}

variable "organization" {
  description = "Name of the organization."
  type        = string
}

variable "workspace" {
  description = "Name of the workspace."
  type        = string
}

module "yaml" {
  source  = "0x022b/yaml-variables/local"
  version = "~> 1.0"

  filename = "${var.dirname}/${var.workspace}.yaml"
}

data "tfe_workspace" "this" {
  name         = var.workspace
  organization = var.organization
}

resource "tfe_variable" "map" {
  for_each = { for v in module.yaml.variables : v.key => v }

  category     = lookup(each.value, "category", "terraform")
  description  = lookup(each.value, "description", null)
  hcl          = lookup(each.value, "hcl", false)
  key          = each.key
  sensitive    = lookup(each.value, "sensitive", false)
  value        = lookup(each.value, "hcl", false) ? replace(jsonencode(each.value.value), "/\"(\\w+?)\":/", "$1=") : tostring(each.value.value)
  workspace_id = data.tfe_workspace.this.id
}

output "variables" {
  description = "YAML file variables as a map."
  value       = { for v in module.yaml.variables : v.key => v.value }
}
