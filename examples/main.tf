variable "ami_name" {
  default = "CentOS Linux 7 x86_64 HVM EBS ENA 1805_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-77ec9308.4"
}

variable "key_name" {
}

variable "name" {
}

variable "root_block_device" {
  default = []
  type = list(map(string))
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
  toggle_allow_all_egress       = "1"
  toggle_allow_all_ingress      = "1"
  toggle_self_allow_all_egress  = "1"
  toggle_self_allow_all_ingress = "1"
  vpc_id                        = var.vpc_id
}

module "instance_none" {
  source = "../"
  count_instances             = 0
  ami_name                    = var.ami_name
  associate_public_ip_address = "false"
  instance_type               = "t2.nano"
  key_name                    = var.key_name
  name                        = var.name
  security_group_attachments  = [module.sg.security_group_id]
  subnet_ids                  = var.subnets
  tags                        = var.tags
  user_data                   = var.input_user_data
}

# validates the default aws_instance resource
module "instance_no_userdata" {
  source = "../"
  count_instances             = 1
  ami_name                    = var.ami_name
  associate_public_ip_address = false
  instance_type               = "t2.nano"
  key_name                    = var.key_name
  name                        = var.name
  security_group_attachments  = [module.sg.security_group_id]
  subnet_ids                  = var.subnets
  tags                        = var.tags
}

module "instance" {
  source = "../"
  count_instances             = 1
  ami_name                    = var.ami_name
  associate_public_ip_address = false
  instance_type               = "t2.nano"
  key_name                    = var.key_name
  name                        = var.name
  security_group_attachments  = [module.sg.security_group_id]
  subnet_ids                  = var.subnets
  tags                        = var.tags
  user_data                   = module.userdata_docker.cloudinit_userdata
}

module "instance_autorecovery" {
  source = "../"
  count_instances             = 1
  ami_name                    = var.ami_name
  associate_public_ip_address = false
  instance_type               = "t2.nano"
  key_name                    = var.key_name
  name                        = format("%s-autorecovery", var.name)
  security_group_attachments  = [module.sg.security_group_id]
  subnet_ids                  = var.subnets
  tags                        = var.tags
  user_data                   = var.input_user_data
  instance_auto_recovery_enabled = true
}

module "instance_custom_root_device" {
  source = "../"
  count_instances             = 1
  ami_name                    = var.ami_name
  associate_public_ip_address = false
  instance_type               = "t2.nano"
  key_name                    = var.key_name
  name                        = format("%s-custom-root", var.name)
  security_group_attachments  = [module.sg.security_group_id]
  subnet_ids                  = var.subnets
  tags                        = var.tags
  user_data                   = module.userdata_docker.cloudinit_userdata
  root_block_device = [{
   delete_on_termination = "true"
   volume_type = "gp2"
   volume_size = 100
  }]
}

module "instance_autorecovery_custom_root_device" {
  source = "../"
  count_instances             = 2
  ami_name                    = var.ami_name
  associate_public_ip_address = false
  instance_type               = "t2.nano"
  key_name                    = var.key_name
  name                        = format("%s-autorecovery-custom-root", var.name)
  security_group_attachments  = [module.sg.security_group_id]
  subnet_ids                  = var.subnets
  tags                        = var.tags
  user_data                   = module.userdata_docker.cloudinit_userdata
  root_block_device = [{
   delete_on_termination = "true"
   volume_type = "gp2"
   volume_size = 100
  }]
  instance_auto_recovery_enabled = true
}


# validate userdata with provisioner
module "instance_autorecovery_custom_root_device_provisioner" {
  source = "../"
  count_instances                = 2
  ami_name                       = var.ami_name
  associate_public_ip_address    = false
  instance_type                  = "t2.nano"
  key_name                       = var.key_name
  name                           = format("%s-autorecovery-custom-root", var.name)
  security_group_attachments     = [module.sg.security_group_id]
  subnet_ids                     = var.subnets
  tags                           = var.tags
  user_data                      = module.userdata_docker.cloudinit_userdata
  root_block_device = [{
   delete_on_termination = "true"
   volume_type           = "gp2"
   volume_size           = 100
  }]
  instance_auto_recovery_enabled = true
  provisioner_cmdstr             = "echo $AWS_INSTANCE_ID"
  provisioner_ssh_user           = "centos"
}

module "instance_userdata_base64_none" {
  source = "../"
  count_instances             = 0
  ami_name                    = var.ami_name
  associate_public_ip_address = false
  instance_type               = "t2.nano"
  key_name                    = var.key_name
  name                        = var.name
  security_group_attachments  = [module.sg.security_group_id]
  subnet_ids                  = var.subnets
  tags                        = var.tags
  user_data_base64            = base64gzip(var.input_user_data)
}


module "instance_userdata_base64" {
  source = "../"
  count_instances             = 1
  ami_name                    = var.ami_name
  associate_public_ip_address = false
  instance_type               = "t2.nano"
  key_name                    = var.key_name
  name                        = format("%s-userdatab64", var.name)
  security_group_attachments  = [module.sg.security_group_id]
  subnet_ids                  = var.subnets
  tags                        = var.tags
  user_data_base64            = base64gzip(var.input_user_data)
}

module "instance_userdata_base64_autorecovery" {
  source = "../"
  count_instances             = 1
  ami_name                    = var.ami_name
  associate_public_ip_address = false
  instance_type               = "t2.nano"
  key_name                    = var.key_name
  name                        = format("%s-userdatab64-autorecovery", var.name)
  security_group_attachments  = [module.sg.security_group_id]
  subnet_ids                  = var.subnets
  tags                        = var.tags
  user_data_base64            = base64gzip(var.input_user_data)
  instance_auto_recovery_enabled = true
}

module "instance_userdata_base64_custom_root_device" {
  source = "../"
  count_instances             = 1
  ami_name                    = var.ami_name
  associate_public_ip_address = false
  instance_type               = "t2.nano"
  key_name                    = var.key_name
  name                        = format("%s-custom-root", var.name)
  security_group_attachments  = [module.sg.security_group_id]
  subnet_ids                  = var.subnets
  tags                        = var.tags
  user_data_base64            = base64gzip(var.input_user_data)
  root_block_device = [{
   delete_on_termination = "true"
   volume_type = "gp2"
   volume_size = 100
  }]
}

module "instance_userdata_base64_autorecovery_custom_root_device" {
  source = "../"
  count_instances             = 2
  ami_name                    = var.ami_name
  associate_public_ip_address = false
  instance_type               = "t2.nano"
  key_name                    = var.key_name
  name                        = format("%s-userdatab64-autorecovery-custom-root", var.name)
  security_group_attachments  = [module.sg.security_group_id]
  subnet_ids                  = var.subnets
  tags                        = var.tags
  user_data_base64            = base64gzip(var.input_user_data)
  user_data                   = ""
  root_block_device = [{
   delete_on_termination = "true"
   volume_type = "gp2"
   volume_size = 100
  }]
  instance_auto_recovery_enabled = true
}

# validate userdata_base64 with provisioner
module "instance_userdata_base64_autorecovery_custom_root_device_provisioner" {
  source = "../"
  count_instances                = 2
  ami_name                       = var.ami_name
  associate_public_ip_address    = false
  instance_type                  = "t2.nano"
  key_name                       = var.key_name
  name                           = format("%s-autorecovery-custom-root", var.name)
  security_group_attachments     = [module.sg.security_group_id]
  subnet_ids                     = var.subnets
  tags                           = var.tags
  user_data_base64               = base64gzip(var.input_user_data)
  root_block_device = [{
   delete_on_termination = "true"
   volume_type           = "gp2"
   volume_size           = 100
  }]
  instance_auto_recovery_enabled = true
  provisioner_cmdstr             = "echo $AWS_INSTANCE_ID"
  provisioner_ssh_user           = "centos"
}


# outputs
# instance ids
output "aws_instance_ids" {
  value = concat(
    module.instance_no_userdata.aws_instance_ids,
    module.instance.aws_instance_ids,
    module.instance_autorecovery.aws_instance_ids,
    module.instance_custom_root_device.aws_instance_ids,
    module.instance_autorecovery_custom_root_device.aws_instance_ids,
    module.instance_autorecovery_custom_root_device_provisioner.aws_instance_ids,
    module.instance_userdata_base64.aws_instance_ids,
    module.instance_userdata_base64_autorecovery.aws_instance_ids,
    module.instance_userdata_base64_custom_root_device.aws_instance_ids,
    module.instance_userdata_base64_autorecovery_custom_root_device.aws_instance_ids,
    module.instance_userdata_base64_autorecovery_custom_root_device_provisioner.aws_instance_ids
  )
}


# private ips
output "aws_instance_private_ips" {
  value = concat(
    module.instance_no_userdata.aws_instance_private_ips,
    module.instance.aws_instance_private_ips,
    module.instance_autorecovery.aws_instance_private_ips,
    module.instance_custom_root_device.aws_instance_private_ips,
    module.instance_autorecovery_custom_root_device.aws_instance_private_ips,
    module.instance_autorecovery_custom_root_device_provisioner.aws_instance_private_ips,
    module.instance_userdata_base64.aws_instance_private_ips,
    module.instance_userdata_base64_autorecovery.aws_instance_private_ips,
    module.instance_userdata_base64_custom_root_device.aws_instance_private_ips,
    module.instance_userdata_base64_autorecovery_custom_root_device.aws_instance_private_ips,
    module.instance_userdata_base64_autorecovery_custom_root_device_provisioner.aws_instance_private_ips
  )
}

# private dns
output "aws_instance_private_dns" {
  value = concat(
    module.instance_no_userdata.aws_instance_private_dns,
    module.instance.aws_instance_private_dns,
    module.instance_autorecovery.aws_instance_private_dns,
    module.instance_custom_root_device.aws_instance_private_dns,
    module.instance_autorecovery_custom_root_device.aws_instance_private_dns,
    module.instance_autorecovery_custom_root_device_provisioner.aws_instance_private_dns,
    module.instance_userdata_base64.aws_instance_private_dns,
    module.instance_userdata_base64_autorecovery.aws_instance_private_dns,
    module.instance_userdata_base64_custom_root_device.aws_instance_private_dns,
    module.instance_userdata_base64_autorecovery_custom_root_device.aws_instance_private_dns,
    module.instance_userdata_base64_autorecovery_custom_root_device_provisioner.aws_instance_private_dns
  )
}

# public ips
output "aws_public_ips" {
  value = concat(
    module.instance_no_userdata.aws_instance_public_ips,
    module.instance.aws_instance_public_ips,
    module.instance_autorecovery.aws_instance_public_ips,
    module.instance_custom_root_device.aws_instance_public_ips,
    module.instance_autorecovery_custom_root_device.aws_instance_public_ips,
    module.instance_autorecovery_custom_root_device_provisioner.aws_instance_public_ips,
    module.instance_userdata_base64.aws_instance_public_ips,
    module.instance_userdata_base64_autorecovery.aws_instance_public_ips,
    module.instance_userdata_base64_custom_root_device.aws_instance_public_ips,
    module.instance_userdata_base64_autorecovery_custom_root_device.aws_instance_public_ips,
    module.instance_userdata_base64_autorecovery_custom_root_device_provisioner.aws_instance_public_ips
  )
}


# public dns
output "aws_public_dns" {
  value = concat(
    module.instance_no_userdata.aws_instance_public_dns,
    module.instance.aws_instance_public_dns,
    module.instance_autorecovery.aws_instance_public_dns,
    module.instance_custom_root_device.aws_instance_public_dns,
    module.instance_autorecovery_custom_root_device.aws_instance_public_dns,
    module.instance_userdata_base64.aws_instance_public_dns,
    module.instance_userdata_base64_autorecovery.aws_instance_public_dns,
    module.instance_userdata_base64_custom_root_device.aws_instance_public_dns,
    module.instance_userdata_base64_autorecovery_custom_root_device.aws_instance_public_dns,
  )
}

# aws instance list of objects
output "aws_instances" {
  value = concat(
    module.instance_no_userdata.aws_instances,
    module.instance.aws_instances,
    module.instance_autorecovery.aws_instances,
    module.instance_custom_root_device.aws_instances,
    module.instance_autorecovery_custom_root_device.aws_instances,
    module.instance_userdata_base64.aws_instances,
    module.instance_userdata_base64_autorecovery.aws_instances,
    module.instance_userdata_base64_custom_root_device.aws_instances,
    module.instance_userdata_base64_autorecovery_custom_root_device.aws_instances,
  )
}
