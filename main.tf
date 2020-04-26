data "aws_region" "region" {}

data "aws_ami" "ami" {
  count = var.use_ami_datasource ? 1 : 0

  most_recent = true
  owners      = var.ami_owners
  filter {
    name   = "name"
    values = [var.ami_name]
  }
}

# optionally create keypair
resource "aws_key_pair" "key_pair" {
  count      = var.key_public_key_material != "" ? 1 : 0
  key_name   = var.key_name != "" ? var.key_name : var.name
  public_key = var.key_public_key_material
}


locals {
  ami_id        = var.ami_id == "" ? join("", data.aws_ami.ami.*.id) : var.ami_id
  key_pair_name = var.key_public_key_material != "" ? join(",", aws_key_pair.key_pair.*.key_name) : var.key_name
}

resource "aws_instance" "instance" {
  count = length(var.provisioner_cmdstr) == 0 ? var.count_instances : 0

  ami                         = local.ami_id
  associate_public_ip_address = var.associate_public_ip_address
  disable_api_termination     = var.disable_api_termination
  iam_instance_profile        = var.iam_instance_profile
  instance_type               = var.instance_type
  key_name                    = local.key_pair_name
  source_dest_check           = var.source_dest_check
  subnet_id                   = element(var.subnet_ids, count.index)
  vpc_security_group_ids      = var.security_group_attachments
  private_ip                  = length(var.private_ips) > 0 ? element(var.private_ips, count.index) : var.private_ip

  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
      iops                  = lookup(root_block_device.value, "iops", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", "gp2")
      encrypted             = lookup(root_block_device.value, "encrypted", true)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
      device_name           = lookup(ebs_block_device.value, "device_name", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp2")
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      encrypted             = lookup(ebs_block_device.value, "encrypted", true)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device
    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = lookup(ephemeral_block_device.value, "no_device", null)
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interface
    content {
      device_index          = network_interface.value.device_index
      network_interface_id  = lookup(network_interface.value, "network_interface_id", null)
      delete_on_termination = lookup(network_interface.value, "delete_on_termination", false)
    }
  }

  user_data        = var.user_data
  user_data_base64 = var.user_data_base64
  tags = merge(
    {
      "Name" = var.count_instances > 1 || var.add_num_suffix ? format("%s-%d", var.name, count.index + 1) : var.name
    },
    var.tags
  )

  volume_tags = merge(
    {
      "Name" = var.count_instances > 1 || var.add_num_suffix ? format("%s-%d", var.name, count.index + 1) : var.name
    },
    var.tags,
    var.volume_tags
  )

  lifecycle {
    ignore_changes = [
      volume_tags["kubernetes.io/created-for/pv/name"],
      volume_tags["kubernetes.io/created-for/pvc/name"],
      volume_tags["kubernetes.io/created-for/pvc/namespace"]
    ]
  }
}


resource "aws_instance" "instance_and_provisioner" {
  count = length(var.provisioner_cmdstr) > 0 ? var.count_instances : 0

  ami                         = local.ami_id
  associate_public_ip_address = var.associate_public_ip_address
  disable_api_termination     = var.disable_api_termination
  iam_instance_profile        = var.iam_instance_profile
  instance_type               = var.instance_type
  key_name                    = local.key_pair_name
  source_dest_check           = var.source_dest_check
  subnet_id                   = element(var.subnet_ids, count.index)
  vpc_security_group_ids      = var.security_group_attachments
  private_ip                  = length(var.private_ips) > 0 ? element(var.private_ips, count.index) : var.private_ip

  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = lookup(ebs_block_device.value, "device_name", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device
    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = lookup(ephemeral_block_device.value, "no_device", null)
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interface
    content {
      device_index          = network_interface.value.device_index
      network_interface_id  = lookup(network_interface.value, "network_interface_id", null)
      delete_on_termination = lookup(network_interface.value, "delete_on_termination", false)
    }
  }

  user_data        = var.user_data
  user_data_base64 = var.user_data_base64
  tags = merge(
    {
      "Name" = var.count_instances > 1 || var.add_num_suffix ? format("%s-%d", var.name, count.index + 1) : var.name
    },
    var.tags
  )

  volume_tags = merge(
    {
      "Name" = var.count_instances > 1 || var.add_num_suffix ? format("%s-%d", var.name, count.index + 1) : var.name
    },
    var.tags,
    var.volume_tags
  )

  lifecycle {
    ignore_changes = [
      volume_tags["kubernetes.io/created-for/pv/name"],
      volume_tags["kubernetes.io/created-for/pvc/name"],
      volume_tags["kubernetes.io/created-for/pvc/namespace"]
    ]
  }

  # remote-exec validates ssh is running before running additional provisioners
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = ! var.provisioner_ssh_public_ip ? self.private_ip : self.public_ip
      user        = var.provisioner_ssh_user
      private_key = length(var.provisioner_ssh_key_path) > 0 ? file(var.provisioner_ssh_key_path) : ""
    }

    inline = [
      "echo 'ssh connection successful!'"
    ]
  }

  provisioner "local-exec" {
    command = var.provisioner_cmdstr
    environment = {
      AWS_INSTANCE_ID          = self.id
      AWS_INSTANCE_PRIVATE_IP  = self.private_ip
      AWS_INSTANCE_PRIVATE_DNS = self.private_dns
      AWS_INSTANCE_PUBLIC_IP   = self.public_ip
      AWS_INSTANCE_PUBLIC_DNS  = self.public_dns
    }
  }
}


locals {
  aws_instance_ids = [
    for i in compact(concat(
      aws_instance.instance.*.id,
    aws_instance.instance_and_provisioner.*.id)) :
    i
  ]
}

resource "aws_cloudwatch_metric_alarm" "instance_auto_recovery" {
  count = var.instance_auto_recovery_enabled ? var.count_instances : 0

  alarm_name          = format("autorecover-%s-%s", var.name, element(local.aws_instance_ids, count.index))
  namespace           = "AWS/EC2"
  alarm_description   = "EC2 instance auto recovery"
  alarm_actions       = [format("arn:aws:automate:%s:ec2:recover", data.aws_region.region.name)]
  evaluation_periods  = "5"
  period              = "60"
  statistic           = "Minimum"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  metric_name         = "StatusCheckFailed_System"

  dimensions = {
    InstanceId = element(local.aws_instance_ids, count.index)
  }
}
