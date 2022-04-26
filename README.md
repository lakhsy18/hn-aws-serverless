# Deploy a Python Function to AWS Lambda and expose it through API Gateway

## Basic usage

The code in main.tf shows how to deploy a Python function to AWS Lambda and
integrate it with API Gateway.Since each Lambda function requires an attached Execution Role, a new role is
deployed and attached it to the lambda function. The code also expects a
zip archive that already exists. If you'd like to build the archive through
terraform, please see the code in the main.tf file.

using module "lambda-fuction" to create lambda function.

```hcl
module "lambda-function" {
  source = "./modules/lambda-function"
  function_name = "python-function"
  description   = "Lambda function that returns an HTTP response."
  filename      = data.archive_file.lambda.output_path
  runtime       = "python3.8"
  handler       = "hello.lambda_handler"
  timeout       = 30
  memory_size   = 128
}
```

using module "api_gateway" to create and add integration.
```hcl
module "api_gateway" {
  source = "./modules/api-gateway"
  integration_uri = module.lambda-function.function.invoke_arn
  function_name = "python-function"
}
```


## Instructions to deploy and test

### Cloning the repository

``` bash
git clone https://github.com/lakhsy18/hn-aws-serverless.git
cd hn-aws-serverless
```

### Initializing Terraform

Run `terraform init` to initialize the example and download providers and the module.

### Planning the example

Run `terraform plan` to see a plan of the changes.

### Applying the example

Run `terraform apply` to create the resources.
You will see a plan of the changes and Terraform will prompt you for approval to actually apply the changes.
It will provide the base URL to invoke the API. Append /hello to the base URL to get response "hello"

API can be accessed now with the URL
https://ucjxvlxo07.execute-api.eu-central-1.amazonaws.com/serverless_lambda_stage/hello

### Destroying the example

Run `terraform destroy` to destroy all resources again.

### GibHub Workflows 

On a pull request and push to 'dev' branch will trigger the GibHub workflow test.yml which runs a test to create
a lambda function using lambda-function module. 

On a pull request and push to 'master' branch will run the aws-deployment.yml and updates the infrastructure in AWS. 



