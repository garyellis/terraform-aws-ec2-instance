output "aws_instance_ids" {
  value = [
    for i in compact(concat(aws_instance.instance_with_user_data.*.id, aws_instance.instance_with_user_data_base64.*.id)):
      i
  ]
}

output "aws_instance_private_ips" {
  value = [
    for i in compact(concat(aws_instance.instance_with_user_data.*.private_ip, aws_instance.instance_with_user_data_base64.*.private_ip)):
      i
  ]
}

output "aws_instance_public_ips" {
  value = [
    for i in compact(concat(aws_instance.instance_with_user_data.*.public_ip, aws_instance.instance_with_user_data_base64.*.public_ip)):
      i
  ]
}

output "aws_instance_private_dns" {
  value = [
    for i in compact(concat(aws_instance.instance_with_user_data.*.private_dns, aws_instance.instance_with_user_data_base64.*.private_dns)):
      i
  ]
}

output "aws_instance_public_dns" {
  value = [
    for i in compact(concat(aws_instance.instance_with_user_data.*.public_dns, aws_instance.instance_with_user_data_base64.*.public_dns)):
      i
  ]
}
