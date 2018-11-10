data "aws_ami" "ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["${var.ami_name}"]
  }
}

# optionally create keypair
resource "aws_key_pair" "key_pair" {
  count                   = "${var.key_public_key_material != "" ? 1 : 0}"
  key_name                = "${var.key_name != "" ? var.key_name : var.name}"
  public_key              = "${var.key_public_key_material}"
}


locals {
  key_pair_name =  "${var.key_public_key_material != "" ? join(",", aws_key_pair.key_pair.*.key_name) : var.key_name}"
}


resource "aws_instance" "instance_with_user_data" {
  count                       = "${var.user_data_base64 != "" ? 0 : var.count_instances}"

  ami                         = "${var.ami_id == "" ? data.aws_ami.ami.id : var.ami_id}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  disable_api_termination     = "${var.disable_api_termination}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${local.key_pair_name}"
  subnet_id                   = "${element(var.subnet_ids, count.index)}"
  vpc_security_group_ids      = ["${var.security_group_attachments}"]

  user_data                   = "${var.user_data}"
  tags                        = "${merge(map("Name", var.name), var.tags)}"
}


resource "aws_instance" "instance_with_user_data_base64" {
  count                       = "${var.user_data_base64 != "" ? var.count_instances : 0}"

  ami                         = "${var.ami_id == "" ? data.aws_ami.ami.id : var.ami_id}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  disable_api_termination     = "${var.disable_api_termination}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${element(var.subnet_ids, count.index)}"
  vpc_security_group_ids      = ["${var.security_group_attachments}"]

  user_data_base64            = "${var.user_data_base64}"
  tags                        = "${merge(map("Name", var.name), var.tags)}"
}
