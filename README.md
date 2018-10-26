# tf_module_aws_instance
This terraform module creates a generic ec2 instance.

* n number of aws ec2 instances
* optionally creates an ec2 keypair
* accepts cloud-init gzip+base64 userdata
* accepts cloud-init plain text userdata
* toggle api termination protection
* accepts a map of tags
