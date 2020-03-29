variable "ami_name" {
  default = "CentOS Linux 7 x86_64 HVM EBS ENA 1805_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-77ec9308.4"
}

variable "key_name" {
}

variable "name" {
}

variable "root_block_device" {
  type = list(map(string))
  default = [
    {
      delete_on_termination = true
      volume_type           = "gp2"
      volume_size           = 20
      encrypted             = true
    }
  ]
}

variable "ebs_block_device" {
  type    = list(map(string))
  default = [
    {
      delete_on_termination = true
      device_name = "/dev/xvdb"
      volume_type = "gp2"
      volume_size = 1
      encrypted   = true
    },
    {
      delete_on_termination = true
      device_name = "/dev/xvdc"
      volume_type = "gp2"
      volume_size = 2
      encrypted   = true
    }
  ]
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "input_user_data" {
  type = string
  default = "echo foo bar"
}


module "userdata_docker" {
  source = "github.com/garyellis/tf_module_cloud_init"

  base64_encode          = false
  gzip                   = false
  install_docker         = true
  install_docker_compose = true
}


module "sg" {
  source = "github.com/garyellis/tf_module_aws_security_group"

  description                   = format("%s security group", var.name)
  egress_cidr_rules             = []
  egress_security_group_rules   = []
  ingress_cidr_rules            = []
  ingress_security_group_rules  = []
  name                          = var.name
  tags                          = var.tags
  toggle_allow_all_egress       = true
  toggle_allow_all_ingress      = true
  toggle_self_allow_all_egress  = true
  toggle_self_allow_all_ingress = true
  vpc_id                        = var.vpc_id
}

module "instance_none" {
  source = "../"

  count_instances             = 0
  name                        = format("%s-none", var.name)
  ami_name                    = var.ami_name
  user_data                   = var.input_user_data
  instance_type               = "t2.nano"
  key_name                    = var.key_name
  associate_public_ip_address = "false"
  security_group_attachments  = [module.sg.security_group_id]
  subnet_ids                  = var.subnets
  tags                        = var.tags
}

# validates an aws instance with minimal configuration
module "instance_minimal" {
  source = "../"
  count_instances             = 1
  ami_name                    = var.ami_name
  use_ami_datasource          = true
  associate_public_ip_address = false
  instance_type               = "t2.nano"
  key_name                    = var.key_name
  name                        = format("%s-minimal", var.name)
  security_group_attachments  = [module.sg.security_group_id]
  subnet_ids                  = var.subnets
  tags                        = var.tags
}

module "instance_block_device_autorecovery" {
  source = "../"

  count_instances             = 1
  name                        = format("%s-blockdevices-autorecovery", var.name)
  ami_name                    = var.ami_name
  use_ami_datasource          = true
  user_data                   = module.userdata_docker.cloudinit_userdata
  instance_type               = "t2.nano"
  key_name                    = var.key_name
  associate_public_ip_address = false
  security_group_attachments  = [module.sg.security_group_id]
  subnet_ids                  = var.subnets
  tags                        = var.tags


  root_block_device           = var.root_block_device
  ebs_block_device            = var.ebs_block_device
  instance_auto_recovery_enabled = true
}


# validate instance with provisioner
module "instance_block_device_autorecovery_provisioner" {
  source = "../"

  count_instances             = 2
  name                        = format("%s-blockdevices-autorecovery-provisioner", var.name)
  ami_name                    = var.ami_name
  use_ami_datasource          = true
  user_data                   = module.userdata_docker.cloudinit_userdata
  instance_type               = "t2.nano"
  key_name                    = var.key_name
  associate_public_ip_address = false
  security_group_attachments  = [module.sg.security_group_id]
  subnet_ids                  = var.subnets
  tags                        = var.tags


  root_block_device           = var.root_block_device
  ebs_block_device            = var.ebs_block_device
  instance_auto_recovery_enabled = true
  provisioner_cmdstr             = "echo $AWS_INSTANCE_ID"
  provisioner_ssh_user           = "centos"
}

# instance ids
output "aws_instance_ids" {
  value = concat(
    module.instance_minimal.aws_instance_ids,
  )
}


# private ips
output "aws_instance_private_ips" {
  value = concat(
    module.instance_minimal.aws_instance_private_ips,
  )
}

# private dns
output "aws_instance_private_dns" {
  value = concat(
    module.instance_minimal.aws_instance_private_dns,
  )
}

# public ips
output "aws_public_ips" {
  value = concat(
    module.instance_minimal.aws_instance_public_ips,
  )
}


# public dns
output "aws_public_dns" {
  value = concat(
    module.instance_minimal.aws_instance_public_dns,
  )
}

# aws instance list of objects
output "aws_instances" {
  value = concat(
    module.instance_minimal.aws_instances,
  )
}
