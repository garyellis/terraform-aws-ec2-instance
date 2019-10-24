
variable "use_ami_datasource" {
  description = "use an ami datasource to lookup ami id"
  type = bool
  default = false
}

variable "ami_id" {
  description = "The ami id"
  type = string
  default = ""
}

variable "ami_name" {
  description = "the ami name"
  type = string
  default = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server*"
}

variable "ami_owners" {
  description = "the ami owner. defaults to aws marketplace owner id (is a required arg for aws_ami datasource)"
  type = list(string)
  default = ["679593333241"]
}

variable "associate_public_ip_address" {
  description = "Associate public ip address when subnet_id is attached to an igw"
  type = bool
  default = true
}

variable "count_instances" {
  description = "the number of instances"
  type = number
  default = "0"
}

variable "disable_api_termination" {
  description = "protect from accidental ec2 instance termination"
  type = bool
  default = false
}

variable "iam_instance_profile" {
  description = "the ec2 instance profile"
  type = string
  default = ""
}

variable "instance_auto_recovery_enabled" {
  description = "enable instance recovery cloudwatch alarm"
  type = bool
  default = false
}

variable "instance_type" {
  description = "the aws instance type"
  type = string
  default = "t2.medium"
}

variable "key_name" {
  description = "assign a keypair to the ec2 instance. Overrides the default keypair name when var.key_public_key_material and var.key_name are set"
  type = string
  default = ""
}

variable "key_public_key_material" {
  description = "Import ssh public key to an aws keypair. Keypair name defaults to var.name"
  type = string
  default = ""
}

variable "name" {
  description = "the resources name"
  type = string
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  type        = string
  default     = ""
}

variable "private_ips" {
  description = "A list of private IPs associated to the EC2 instance. This length should be the instances count"
  type        = list(string)
  default     = []
}

variable "root_block_device" {
  description = "customize the root block device configuration"
  type = list(map(string))
  default = []
}

variable "ebs_block_device" {
  description = "additional ebs volumes to attach to the instance"
  type = list(map(string))
  default = []
}

variable "security_group_attachments" {
  description = "a list of security group ids that will attach to rancher server"
  type = list(string)
  default = []
}

variable "source_dest_check" {
  description = "source dest checking enabled"
  type = bool
  default = true
}

variable "subnet_ids" {
  description = "A list of subnet ids"
  type = list(string)
}

variable "tags" {
  description = "provide a map of aws tags"
  type = map(string)
  default = {}
}


variable "user_data" {
  description = "base64 encoded binary data. use when userdata is base64 encoded gzip data"
  type = string
  default = ""
}

variable "user_data_base64" {
  description = "base64 encoded binary data. use when userdata is base64 encoded gzip data"
  type = string
  default = ""
}

variable "provisioner_cmdstr" {
  description = "An optional local-exec provisioner cmd string"
  type = string
  default = ""
}

variable "provisioner_ssh_user" {
  description = ""
  type = string
  default = ""
}

variable "provisioner_ssh_key_path" {
  description = ""
  type = string
  default = ""
}

variable "provisioner_ssh_public_ip" {
  description = "use the instance public ip address for remote-exec provisioner"
  type = bool
  default = false
}
