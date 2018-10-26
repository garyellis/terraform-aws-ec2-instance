output "aws_instance_ids" {
  value = "${split(",", join(",", aws_instance.instance_with_user_data.*.id, aws_instance.instance_with_user_data_base64.*.id))}"
}

output "aws_instance_private_ips" {
  value = "${split(",", join(",", aws_instance.instance_with_user_data.*.id, aws_instance.instance_with_user_data_base64.*.private_ip))}"
}
