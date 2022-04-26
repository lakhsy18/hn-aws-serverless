package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestUnitComplete(t *testing.T) {
	t.Parallel()

	functionName := strings.ToLower(fmt.Sprintf("lambda-tester-%s", random.UniqueId()))
	description := "A Lambda Function for the purpose of Unit Testing."

	handler := "hello.lambda_handler"
	runtime := "python3.8"
	publish := false
	memorySize := float64(128)
	timeout := float64(3)

	s3Bucket := "bucket-primary"
	s3Key := "hello.py.zip"

	terraformOptions := &terraform.Options{
		// The path to where the Terraform code is located
		TerraformDir: "../modules/lambda-function",
		Vars: map[string]interface{}{
			"function_name":    functionName,
			"description":      description,
			"s3_bucket": s3Bucket,
			"s3_key": s3Key,
			"handler":          handler,
			"runtime":          runtime,
			"publish":          publish,
			"memory_size":      memorySize,
			"timeout":          timeout,
		},
		Upgrade: true,
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
	// stdout := terraform.Plan(t, terraformOptions)

	// resourceCount := terraform.GetResourceCount(t, stdout)
	// assert.Equal(t, 0, resourceCount.Add, "No resources should have been created. Found %d instead.", resourceCount.Add)
	// assert.Equal(t, 0, resourceCount.Change, "No resources should have been changed. Found %d instead.", resourceCount.Change)
	// assert.Equal(t, 0, resourceCount.Destroy, "No resources should have been destroyed. Found %d instead.", resourceCount.Destroy)

	outputs := terraform.OutputAll(t, terraformOptions)
	functionOutputs := outputs["all"].(map[string]interface{})["function"].(map[string]interface{})

	//Assert if outputs match the desired variable inputs
	assert.Equal(t, functionName, functionOutputs["function_name"])
	// assert.Equal(t, description, functionOutputs["description"])
	// assert.Equal(t, handler, functionOutputs["handler"])
	// assert.Equal(t, runtime, functionOutputs["runtime"])
	// assert.Equal(t, memorySize, functionOutputs["memory_size"])
	// assert.Equal(t, timeout, functionOutputs["timeout"])
}
