output "aws_instance_ids" {
  value = [
    for i in compact(concat(
        aws_instance.with_user_data.*.id,
        aws_instance.with_user_data_base64.*.id,
        aws_instance.with_user_data_and_provisioner.*.id,
        aws_instance.with_user_data_base64_and_provisioner.*.id)):
      i
  ]
}

output "aws_instance_private_ips" {
  value = [
    for i in compact(concat(
        aws_instance.with_user_data.*.private_ip,
        aws_instance.with_user_data_base64.*.private_ip,
        aws_instance.with_user_data_and_provisioner.*.private_ip,
        aws_instance.with_user_data_base64_and_provisioner.*.private_ip,
        )):
      i
  ]
}

output "aws_instance_public_ips" {
  value = [
    for i in compact(concat(
        aws_instance.with_user_data.*.public_ip,
        aws_instance.with_user_data_base64.*.public_ip,
        aws_instance.with_user_data_and_provisioner.*.public_ip,
        aws_instance.with_user_data_base64_and_provisioner.*.public_ip)):
      i
  ]
}

output "aws_instance_private_dns" {
  value = [
    for i in compact(concat(
        aws_instance.with_user_data.*.private_dns,
        aws_instance.with_user_data_base64.*.private_dns,
        aws_instance.with_user_data_and_provisioner.*.private_dns,
        aws_instance.with_user_data_base64_and_provisioner.*.private_dns)):
      i
  ]
}

output "aws_instance_public_dns" {
  value = [
    for i in compact(concat(
        aws_instance.with_user_data.*.public_dns,
        aws_instance.with_user_data_base64.*.public_dns,
        aws_instance.with_user_data_and_provisioner.*.public_dns,
        aws_instance.with_user_data_base64_and_provisioner.*.public_dns)):
      i
  ]
}

output "aws_instances" {
  value = [
    for i in concat(
        aws_instance.with_user_data[*],
        aws_instance.with_user_data_base64[*],
        aws_instance.with_user_data_and_provisioner[*],
        aws_instance.with_user_data_base64_and_provisioner[*]):
      { "instance_id" = i.id, "private_dns" = i.private_dns, "private_ip" = i.private_ip, "public_dns" = i.public_dns, "public_ip" = i.public_ip }
  ]
}
