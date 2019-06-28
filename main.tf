data "aws_region" "region" {}

data "aws_ami" "ami" {
  most_recent = true
  owners = var.ami_owners
  filter {
    name = "name"
    values = [var.ami_name]
  }
}

# optionally create keypair
resource "aws_key_pair" "key_pair" {
  count                   = var.key_public_key_material != "" ? 1 : 0
  key_name                = var.key_name != "" ? var.key_name : var.name
  public_key              = var.key_public_key_material
}


locals {
  key_pair_name =  var.key_public_key_material != "" ? join(",", aws_key_pair.key_pair.*.key_name) : var.key_name
}


resource "aws_instance" "instance_with_user_data" {
  count                       = length(var.user_data) > 0 && length(var.user_data_base64) == 0 ? var.count_instances : 0

  ami                         = var.ami_id == "" ? data.aws_ami.ami.id : var.ami_id
  associate_public_ip_address = var.associate_public_ip_address
  disable_api_termination     = var.disable_api_termination
  iam_instance_profile        = var.iam_instance_profile
  instance_type               = var.instance_type
  key_name                    = local.key_pair_name
  source_dest_check           = var.source_dest_check
  subnet_id                   = var.subnet_ids[count.index]
  vpc_security_group_ids      = var.security_group_attachments

  dynamic "root_block_device" {
    for_each = [for i in var.root_block_device: {
      delete_on_termination = i.delete_on_termination
      volume_type           = i.volume_type
      volume_size           = i.volume_size
    }]

    content {
      delete_on_termination = root_block_device.value.delete_on_termination
      volume_type           = root_block_device.value.volume_type
      volume_size           = root_block_device.value.volume_size
    }
  }


  user_data                   = var.user_data
  tags                        = merge(map("Name", var.name), var.tags)
}


resource "aws_instance" "instance_with_user_data_base64" {
  count                       = length(var.user_data) == 0 && length(var.user_data_base64) > 0 ? var.count_instances : 0

  ami                         = var.ami_id == "" ? data.aws_ami.ami.id : var.ami_id
  associate_public_ip_address = var.associate_public_ip_address
  disable_api_termination     = var.disable_api_termination
  iam_instance_profile        = var.iam_instance_profile
  instance_type               = var.instance_type
  key_name                    = var.key_name
  source_dest_check           = var.source_dest_check
  subnet_id                   = element(var.subnet_ids, count.index)
  vpc_security_group_ids      = var.security_group_attachments

  dynamic "root_block_device" {
    for_each = [for i in var.root_block_device: {
      delete_on_termination = i.delete_on_termination
      volume_type           = i.volume_type
      volume_size           = i.volume_size
    }]

    content {
      delete_on_termination = root_block_device.value.delete_on_termination
      volume_type           = root_block_device.value.volume_type
      volume_size           = root_block_device.value.volume_size
    }
  }

  user_data_base64            = var.user_data_base64
  tags                        = merge(map("Name", var.name), var.tags)
}


locals {
  aws_instance_ids = split(",", join(",", aws_instance.instance_with_user_data.*.id, aws_instance.instance_with_user_data_base64.*.id))
}

#locals {
#  aws_instance_ids = [
#    for i in compact(concat(aws_instance.instance_with_user_data.*.id, aws_instance.instance_with_user_data_base64.*.id)):
#      i
#  ]
#}

resource "aws_cloudwatch_metric_alarm" "instance_auto_recovery" {
  count                       = var.instance_auto_recovery_enabled ? var.count_instances : 0

  alarm_name                  = format("autorecover-%s-%s", var.name, element(local.aws_instance_ids, count.index))
  namespace                   = "AWS/EC2"
  alarm_description           = "EC2 instance auto recovery"
  alarm_actions               = [format("arn:aws:automate:%s:ec2:recover",data.aws_region.region.name)]
  evaluation_periods          = "5"
  period                      = "60"
  statistic                   = "Minimum"
  comparison_operator         = "GreaterThanThreshold"
  threshold                   = "0"
  metric_name                 = "StatusCheckFailed_System"

  dimensions = {
    InstanceId = element(local.aws_instance_ids, count.index)
  }
}
