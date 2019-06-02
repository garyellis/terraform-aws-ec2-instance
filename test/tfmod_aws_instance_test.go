package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

// Very basic terraform module that validates terraform apply/destroy
func Test_AwsInstance(t *testing.T) {
	t.Parallel()

	tfOptions := &terraform.Options{
		TerraformDir: "../examples",
		Vars:         map[string]interface{}{},
	}

	defer terraform.Destroy(t, tfOptions)
	terraform.InitAndApply(t, tfOptions)
}
