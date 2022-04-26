# lambda-function module

A terraform module for deploying AWS Serverless lambda function.

- [Module Features](#module-features)
- [Getting Started](#getting-started)
- [Module Argument Reference](#module-argument-reference)
  - [Top-level Arguments](#top-level-arguments)
    - [Module Configuration](#module-configuration)
    - [Lambda Function Resource Configuration](#lambda-function-resource-configuration)
- [Module Outputs](#module-outputs)
- [External Documentation](#external-documentation)
  - [AWS Lambda Documentation](#aws-lambda-documentation)
  - [Terraform AWS Provider Documentation](#terraform-aws-provider-documentation)



## Module Features

- **Standard Module Features**:

  Deploy a local deployment package to AWS Lambda

  Deploy a deployment package located in S3 to AWS Lambda

- **Extended Module Features**:
  Aliases, Permissions

## Getting Started

Most basic usage just setting required arguments:

```hcl
module "terraform-aws-lambda-function" {
  source  = "./modules/lambda-function"
  version = "~> 0.5.0"

  runtime  = "python3.8"
  handler  = "main"
  role_arn = aws_iam_role.hn-lambda.arn
  filename = "deployment.zip"
}
```
## Module Argument Reference

See variables.tf and outputs.tf for details.

### Top-level Arguments

#### Lambda Function Resource Configuration

- [**`function_name`**](#var-function_name): *(**Required** `string`)*<a name="var-function_name"></a>

  A unique name for the Lambda function.

- [**`handler`**](#var-handler): *(Optional `string`)*<a name="var-handler"></a>

  The function entrypoint in the code. This is the name of the method in the code which receives the event and context parameter when this Lambda function is triggered.

- [**`role_arn`**](#var-role_arn): *(**Required** `string`)*<a name="var-role_arn"></a>

  The ARN of the policy that is used to set the permissions boundary for the IAM role for the Lambda function.

- [**`runtime`**](#var-runtime): *(**Required** `string`)*<a name="var-runtime"></a>

  The runtime the Lambda function should run in. A list of all available runtimes can be found here: https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html

  Default is `"[]"`.

- [**`description`**](#var-description): *(Optional `string`)*<a name="var-description"></a>

  A description of what the Lambda function does.

- [**`publish`**](#var-publish): *(Optional `bool`)*<a name="var-publish"></a>

  Whether to publish creation/change as new Lambda function.
  This allows you to use aliases to refer to execute different versions of the function in different environments.

  Default is `false`.

- [**`layer_arns`**](#var-layer_arns): *(Optional `set(string)`)*<a name="var-layer_arns"></a>

  Set of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda function.
  For details see https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html

  Default is `[]`.

- [**`reserved_concurrent_executions`**](#var-reserved_concurrent_executions): *(Optional `number`)*<a name="var-reserved_concurrent_executions"></a>

  The amount of reserved concurrent executions for this Lambda function.
  A value of 0 disables Lambda from being triggered and -1 removes any concurrency limitations.
  For details see https://docs.aws.amazon.com/lambda/latest/dg/invocation-scaling.html

  Default is `-1`.

- [**`s3_bucket`**](#var-s3_bucket): *(Optional `string`)*<a name="var-s3_bucket"></a>

  The S3 bucket location containing the function's deployment package.
  Conflicts with `filename`. This bucket must reside in the same AWS region where you are creating the Lambda function.

- [**`source_code_hash`**](#var-source_code_hash): *(Optional `string`)*<a name="var-source_code_hash"></a>

  Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the package file specified with either `filename` or `s3_key`.

- [**`environment_variables`**](#var-environment_variables): *(Optional `map(string)`)*<a name="var-environment_variables"></a>

  A map of environment variables to pass to the Lambda function.
  AWS will automatically encrypt these with KMS if a key is provided and decrypt them when running the function.

  Default is `{}`.

- [**`kms_key_arn`**](#var-kms_key_arn): *(Optional `string`)*<a name="var-kms_key_arn"></a>

  The ARN for the KMS encryption key that is used to encrypt environment variables. If none is provided when environment variables are in use, AWS Lambda uses a default service key.

- [**`filename`**](#var-filename): *(Optional `string`)*<a name="var-filename"></a>

  The path to the local .zip file that contains the Lambda function source code.

- [**`timeout`**](#var-timeout): *(Optional `number`)*<a name="var-timeout"></a>

  The amount of time the Lambda function has to run in seconds. For details see https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html

  Default is `3`.

- [**`s3_key`**](#var-s3_key): *(Optional `string`)*<a name="var-s3_key"></a>

  The S3 key of an object containing the function's deployment package.
  Conflicts with `filename`.

- [**`s3_object_version`**](#var-s3_object_version): *(Optional `string`)*<a name="var-s3_object_version"></a>

  The object version containing the function's deployment package.
  Conflicts with `filename`.

- [**`memory_size`**](#var-memory_size): *(Optional `number`)*<a name="var-memory_size"></a>

  Amount of memory in MB the Lambda function can use at runtime.
  For details see https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html

  Default is `128`.

- [**`permissions`**](#var-permissions): *(Optional `list(permission)`)*<a name="var-permissions"></a>

  A list of permission objects of external resources (like a CloudWatch Event Rule, SNS, or S3) that should have permission to access the Lambda function.

  Default is `[]`.

  Each `permission` object in the list accepts the following attributes:

  - [**`statement_id`**](#attr-permissions-statement_id): *(**Required** `string`)*<a name="attr-permissions-statement_id"></a>

    A unique statement identifier.

  - [**`action`**](#attr-permissions-action): *(**Required** `string`)*<a name="attr-permissions-action"></a>

    The AWS Lambda action you want to allow in this statement. (e.g. `lambda:InvokeFunction`)

  - [**`principal`**](#attr-permissions-principal): *(**Required** `string`)*<a name="attr-permissions-principal"></a>

    The principal who is getting this permission. e.g. `s3.amazonaws.com`, an AWS account ID, or any valid AWS service principal such as `events.amazonaws.com` or `sns.amazonaws.com`.

  - [**`event_source_token`**](#attr-permissions-event_source_token): *(Optional `string`)*<a name="attr-permissions-event_source_token"></a>

    The Event Source Token to validate. Used with Alexa Skills.

  - [**`qualifier`**](#attr-permissions-qualifier): *(Optional `string`)*<a name="attr-permissions-qualifier"></a>

    Query parameter to specify function version or alias name.
    The permission will then apply to the specific qualified ARN. e.g. `arn:aws:lambda:aws-region:acct-id:function:function-name:2`.

  - [**`source_account`**](#attr-permissions-source_account): *(Optional `string`)*<a name="attr-permissions-source_account"></a>

    This parameter is used for S3 and SES.
    The AWS account ID (without a hyphen) of the source owner.

  - [**`source_arn`**](#attr-permissions-source_arn): *(Optional `string`)*<a name="attr-permissions-source_arn"></a>

    When the principal is an AWS service, the ARN of the specific resource within that service to grant permission to. Without this, any resource from principal will be granted permission – even if that resource is from another account.
    For S3, this should be the ARN of the S3 Bucket.
    For CloudWatch Events, this should be the ARN of the CloudWatch Events Rule.
    For API Gateway, this should be the ARN of the API, as described in
    https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html.

#### Module Configuration

- [**`module_enabled`**](#var-module_enabled): *(Optional `bool`)*<a name="var-module_enabled"></a>

  Specifies whether resources in the module will be created.

  Default is `true`.

## Module Outputs

The following attributes are exported by the module:

- [**`function`**](#output-function): *(`object(function)`)*<a name="output-function"></a>

  All outputs of the `aws_lambda_function` resource."

- [**`permissions`**](#output-permissions): *(`list(permission)`)*<a name="output-permissions"></a>

  A map of all created `aws_lambda_permission` resources keyed by
  `statement_id`.

- [**`module_enabled`**](#output-module_enabled): *(`bool`)*<a name="output-module_enabled"></a>

  Whether this module is enabled.

- [**`module_inputs`**](#output-module_inputs): *(`map(module_inputs)`)*<a name="output-module_inputs"></a>

  A map of all module arguments. Omitted optional arguments will be
  represented with their actual defaults.

## External Documentation

### AWS Lambda Documentation

- General Documentation: https://docs.aws.amazon.com/lambda/latest/dg/welcome.html
- Functions: https://docs.aws.amazon.com/lambda/latest/dg/lambda-functions.html

### Terraform AWS Provider Documentation

- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission


<!-- References -->

[Terraform]: https://www.terraform.io
[AWS]: https://aws.amazon.com/
[Serverless Lambda Functions]: https://aws.amazon.com/lambda/
