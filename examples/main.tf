variable "ami_name" {
  default = "CentOS Linux 7 x86_64 HVM EBS ENA 1805_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-77ec9308.4"
}
variable "instance_auto_recovery_enabled" {
  default = "0"
}

variable "key_name" {
}

variable "name" {
}

variable "root_block_device" {
  default = []
}

variable "subnets" {
  type = "list"
}

variable "vpc_id" {
}

variable "tags" {
  type    = "map"
  default = {}
}

module "sg" {
  source = "github.com/garyellis/tf_module_aws_security_group"

  description                   = "${var.name} security group"
  egress_cidr_rules             = []
  egress_security_group_rules   = []
  ingress_cidr_rules            = []
  ingress_security_group_rules  = []
  name                          = "${var.name}"
  tags                          = "${var.tags}"
  toggle_allow_all_egress       = "1"
  toggle_allow_all_ingress      = "1"
  toggle_self_allow_all_egress  = "1"
  toggle_self_allow_all_ingress = "1"
  vpc_id                        = "${var.vpc_id}"
}

module "instance" {
  source = "../"

  count_instances             = "1"
  ami_name                    = "${var.ami_name}"
  associate_public_ip_address = "false"
  instance_type               = "t2.nano"
  key_name                    = "${var.key_name}"
  name                        = "${var.name}"
  security_group_attachments  = ["${module.sg.security_group_id}"]
  subnet_ids                  = ["${var.subnets}"]
  tags                        = "${var.tags}"
  user_data                   = ""

  instance_auto_recovery_enabled = "${var.instance_auto_recovery_enabled}"
}

module "instance_with_custom_root_block_device" {
  source = "../"

  count_instances             = "1"
  ami_name                    = "${var.ami_name}"
  associate_public_ip_address = "false"
  instance_type               = "t2.nano"
  key_name                    = "${var.key_name}"
  name                        = "${var.name}-custom-root-block-device"
  security_group_attachments  = ["${module.sg.security_group_id}"]
  subnet_ids                  = ["${var.subnets}"]
  tags                        = "${var.tags}"
  user_data                   = ""
  root_block_device = [{
   delete_on_termination = "true"
   volume_type = "gp2"
   volume_size = 50
  }]
  instance_auto_recovery_enabled = "${var.instance_auto_recovery_enabled}"
}
