# tf_module_aws_instance
This terraform module creates an ec2 instance. It supports the following configuration:

* n number of aws ec2 instances
* optionally creates an ec2 keypair
* optionally creates ec2 instance auto recovery cloudwatch alarm
* optional cloud-init gzip+base64 userdata input
* optional cloud-init plain text userdata input
* push provisioning is supported via local exec provisioner
* push provisioning supports node targeting from local-exec provisioner. instance context attributes are exposed as local-exec environment variables.
* toggle api termination protection
* applies a map of tags to all taggable resources


## Terraform version

* v0.12

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| add\_num\_suffix | adds the counter index as a suffix to the instance Name tag | `bool` | `true` | no |
| ami\_id | The ami id | `string` | `""` | no |
| ami\_name | the ami name | `string` | `"ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server*"` | no |
| ami\_owners | the ami owner. defaults to aws marketplace owner id (is a required arg for aws\_ami datasource) | `list(string)` | <pre>[<br>  "679593333241"<br>]</pre> | no |
| associate\_public\_ip\_address | Associate public ip address when subnet\_id is attached to an igw | `bool` | `true` | no |
| count\_instances | the number of instances | `number` | `"0"` | no |
| disable\_api\_termination | protect from accidental ec2 instance termination | `bool` | `false` | no |
| ebs\_block\_device | additional ebs volumes to attach to the instance | `list(map(string))` | `[]` | no |
| ephemeral\_block\_device | configure ephemeral volumes to attach to the instance | `list(map(string))` | `[]` | no |
| iam\_instance\_profile | the ec2 instance profile | `string` | `""` | no |
| instance\_auto\_recovery\_enabled | enable instance recovery cloudwatch alarm | `bool` | `false` | no |
| instance\_type | the aws instance type | `string` | `"t2.medium"` | no |
| key\_name | assign a keypair to the ec2 instance. Overrides the default keypair name when var.key\_public\_key\_material and var.key\_name are set | `string` | `""` | no |
| key\_public\_key\_material | Import ssh public key to an aws keypair. Keypair name defaults to var.name | `string` | `""` | no |
| name | the resources name | `string` | n/a | yes |
| network\_interface | configure network interfaces to attach to the instance | `list(map(string))` | `[]` | no |
| private\_ip | Private IP address to associate with the instance in a VPC | `string` | `""` | no |
| private\_ips | A list of private IPs associated to the EC2 instance. This length should be the instances count | `list(string)` | `[]` | no |
| provisioner\_cmdstr | An optional local-exec provisioner cmd string | `string` | `""` | no |
| provisioner\_ssh\_key\_path | n/a | `string` | `""` | no |
| provisioner\_ssh\_public\_ip | use the instance public ip address for remote-exec provisioner | `bool` | `false` | no |
| provisioner\_ssh\_user | n/a | `string` | `""` | no |
| root\_block\_device | customize the root block device configuration | `list(map(string))` | `[]` | no |
| security\_group\_attachments | a list of security group ids that will attach to rancher server | `list(string)` | `[]` | no |
| source\_dest\_check | source dest checking enabled | `bool` | `true` | no |
| subnet\_ids | A list of subnet ids | `list(string)` | n/a | yes |
| tags | provide a map of aws tags | `map(string)` | `{}` | no |
| use\_ami\_datasource | use an ami datasource to lookup ami id | `bool` | `false` | no |
| user\_data | base64 encoded binary data. use when userdata is base64 encoded gzip data | `string` | n/a | yes |
| user\_data\_base64 | base64 encoded binary data. use when userdata is base64 encoded gzip data | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| aws\_instance\_ids | n/a |
| aws\_instance\_private\_dns | n/a |
| aws\_instance\_private\_ips | n/a |
| aws\_instance\_public\_dns | n/a |
| aws\_instance\_public\_ips | n/a |
| aws\_instances | n/a |
