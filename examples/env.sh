KEY_NAME=garyellis
NAME=tfmod-aws-instance
VPC_NAME=gellis
SUBNET_NAME="private-[abc]"



function get_subnets(){
    aws ec2 describe-subnets --filters Name=vpc-id,Values=$1 | \
    jq -r '.Subnets[] | [.SubnetId, (.Tags[]|select(.Key=="Name").Value)] | @tsv' | \
    awk -v subnet_name="$2" '$0 ~ subnet_name {print $1}'
}


export TF_VAR_key_name=$KEY_NAME
export TF_VAR_name=$NAME

tags=$(printf "%s" "environment_stage = \"$NAME\"")
export TF_VAR_tags={${tags}}


vpc_id=$(aws ec2 describe-vpcs --filter "Name=tag:Name,Values=$VPC_NAME"|jq -r '.Vpcs[].VpcId')
export TF_VAR_vpc_id=$vpc_id

subnets=$(printf '"%s",' $(get_subnets $vpc_id $subnet_name))
export TF_VAR_subnets=[${subnets}]
