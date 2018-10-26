variable "ami_id" {
  description = "The ami id"
  default = ""
}

variable "ami_name" {
  description = "the ami name"
  default = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server*"
}

variable "associate_public_ip_address" {
  description = "Associate public ip address when subnet_id is attached to an igw"
  default = "true"
}

variable "count_instances" {
  description = "the number of instances"
  default = "1"
}

variable "disable_api_termination" {
  description = "protect from accidental ec2 instance termination"
  default = "false"
}

variable "instance_type" {
  description = "the aws instance type"
  default = "t2.medium"
}


variable "key_name" {
  description = "assign a keypair to the ec2 instance. Overrides the default keypair name when var.key_public_key_material and var.key_name are set"
  default = ""
}

variable "key_public_key_material" {
  description = "Import ssh public key to an aws keypair. Keypair name defaults to var.name"
  default = ""
}

variable "name" {
  description = "the resources name"
  default = "rancher-server"
}

variable "security_group_attachments" {
  description = "a list of security group ids that will attach to rancher server"
  default = []
  type = "list"
}

variable "subnet_id" {
  description = "the vpc subnet id"
}

variable "tags" {
  description = "provide a map of aws tags"
  default = {}
  type = "map"
}


variable "user_data" {
  description = "base64 encoded binary data. use when userdata is base64 encoded gzip data"
  default = ""
}

variable "user_data_base64" {
  description = "base64 encoded binary data. use when userdata is base64 encoded gzip data"
  default = ""
}
