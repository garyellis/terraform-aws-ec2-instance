output "aws_instance_ids" {
  value = "${split(",", join(",", aws_instance.instance_with_user_data.*.id, aws_instance.instance_with_user_data_base64.*.id))}"
}

output "aws_instance_private_ips" {
  value = "${split(",", join(",", aws_instance.instance_with_user_data.*.private_ip, aws_instance.instance_with_user_data_base64.*.private_ip))}"
}

output "aws_instance_public_ips" {
  value = "${split(",", join(",", aws_instance.instance_with_user_data.*.public_ip, aws_instance.instance_with_user_data_base64.*.public_ip))}"
}

output "aws_instance_private_dns" {
  value = "${split(",", join(",", aws_instance.instance_with_user_data.*.private_dns, aws_instance.instance_with_user_data_base64.*.private_dns))}"
}
