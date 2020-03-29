output "aws_instance_ids" {
  value = [
    for i in compact(concat(
        aws_instance.instance.*.id,
        aws_instance.instance_and_provisioner.*.id)):
      i
  ]
}

output "aws_instance_private_ips" {
  value = [
    for i in compact(concat(
        aws_instance.instance.*.private_ip,
        aws_instance.instance_and_provisioner.*.private_ip)):
      i
  ]
}

output "aws_instance_public_ips" {
  value = [
    for i in compact(concat(
        aws_instance.instance.*.public_ip,
        aws_instance.instance_and_provisioner.*.public_ip)):
      i
  ]
}

output "aws_instance_private_dns" {
  value = [
    for i in compact(concat(
        aws_instance.instance.*.private_dns,
        aws_instance.instance_and_provisioner.*.private_dns)):
      i
  ]
}

output "aws_instance_public_dns" {
  value = [
    for i in compact(concat(
        aws_instance.instance.*.public_dns,
        aws_instance.instance_and_provisioner.*.public_dns)):
      i
  ]
}

output "aws_instances" {
  value = [
    for i in concat(
        aws_instance.instance[*],
        aws_instance.instance_and_provisioner[*]):
      { "instance_id" = i.id, "private_dns" = i.private_dns, "private_ip" = i.private_ip, "public_dns" = i.public_dns, "public_ip" = i.public_ip }
  ]
}
