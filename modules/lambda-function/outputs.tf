# ----------------------------------------------------------------------------------------------------------------------
# Output variables
# ----------------------------------------------------------------------------------------------------------------------

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  region       = data.aws_region.current.name
  account_id   = data.aws_caller_identity.current.account_id
  function_arn = "arn:aws:lambda:${local.region}:${local.account_id}:function:${var.function_name}"
}

output "function" {
  description = "All outputs of the 'aws_lambda_function' resource."
  value       = try(aws_lambda_function.hn-lambda[0], null)
}

output "permissions" {
  description = "A map of all created 'aws_lambda_permission' resources keyed by statement_id."
  value       = try(aws_lambda_permission.permission, null)
}

# ----------------------------------------------------------------------------------------------------------------------
# Output all input variables
# ----------------------------------------------------------------------------------------------------------------------

output "module_inputs" {
  description = "A map of all module arguments. Omitted optional arguments will be represented with their actual defaults."
  value = {
    description                    = var.description
    environment_variables          = var.environment_variables
    filename                       = var.filename
    function_name                  = var.function_name
    handler                        = var.handler
    kms_key_arn                    = var.kms_key_arn
    layer_arns                     = var.layer_arns
    memory_size                    = var.memory_size
    permissions                    = values(local.permissions)
    publish                        = var.publish
    reserved_concurrent_executions = var.reserved_concurrent_executions
    runtime                        = var.runtime
    role_arn                       = var.role_arn
    lambda_role_name               = var.lambda_role_name
    s3_bucket                      = local.s3_bucket
    s3_key                         = local.s3_key
    s3_object_version              = local.s3_object_version
    source_code_hash               = local.source_code_hash
    timeout                        = var.timeout
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Output module configuration
# ----------------------------------------------------------------------------------------------------------------------

output "module_enabled" {
  description = "Whether the module is enabled."
  value       = var.module_enabled
}

