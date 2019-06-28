# tf_module_aws_instance
This terraform module creates an ec2 instance. It supports the following configuration:

* n number of aws ec2 instances
* optionally creates an ec2 keypair
* optionally creates ec2 instance auto recovery cloudwatch configuration
* accepts cloud-init gzip+base64 userdata
* accepts cloud-init plain text userdata
* toggle api termination protection
* accepts a map of tags

## Terraform version

* v0.12


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami\_id | The ami id | `string` | `""` | no |
| ami\_name | the ami name | `string` | `"ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server*"` | no |
| ami\_owners | the ami owner. defaults to the aws marketplace owner id | `list(string)` | `["679593333241"]` | no |
| associate\_public\_ip\_address | Associate public ip address when subnet_id is attached to an igw | `bool` | `true` | no |
| count\_instances | the number of instances | `bool` | `"1"` | no |
| disable\_api\_termination | protect from accidental ec2 instance termination | `bool` | `false` | no |
| iam\_instance\_profile | the ec2 instance profile | `string` | `""` | no |
| instance\_auto\_recovery\_enabled | enable instance recovery cloudwatch alarm | `bool` | `false` | no |
| instance\_type | the aws instance type | `string` | `"t2.medium"` | no |
| key\_name | assign a keypair to the ec2 instance. Overrides the default keypair name when var.key_public_key_material and var.key_name are set | `string` | `""` | no |
| key\_public\_key\_material | Import ssh public key to an aws keypair. Keypair name defaults to var.name | `string` | `""` | no |
| name | the resources name | `string` | n/a | yes |
| root\_block\_device | customize the root block device configuration | `list(map(string))` | `[]` | no |
| security\_group\_attachments | a list of security group ids that will attach to rancher server | `list(string)` | `[]` | no |
| source\_dest\_check | source dest checking enabled | `string` | `"true"` | no |
| subnet\_ids | A list of subnet ids | `list(string)` | n/a | yes |
| tags | provide a map of aws tags | `map(string)` | `{}` | no |
| user\_data | base64 encoded binary data. use when userdata is base64 encoded gzip data | `string` | `""` | no |
| user\_data\_base64 | base64 encoded binary data. use when userdata is base64 encoded gzip data | `string` | `""` | no |

## Outputs

| Name | Description | Type |
|------|-------------|:------:|
| aws\_instance\_ids |  a list of instances ids | `list(string)` |
| aws\_instance\_private\_dns | a list of the instances dns names  | `list(string)` |
| aws\_instance\_private\_ips | a list of the instances private ips (1st ip of 1st interface) | `list(string)` |
| aws\_instance\_public\_ips | a list of the instances public ips (1st ip of 1st interface) | `list(string)` |

## Usage
```

```