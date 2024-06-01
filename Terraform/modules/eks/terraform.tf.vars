region              = "ap-northeast-1"
vpc_cidr_block      = "10.0.0.0/16"
public_subnet_a_cidr = "10.0.0.0/24"
public_subnet_c_cidr = "10.0.1.0/24"
private_subnet_a_cidr = "10.0.2.0/24"
private_subnet_c_cidr = "10.0.3.0/24"
cluster_name        = "EOF-cluster"
kubernetes_version  = "1.28"
node_group_min_size = 2
node_group_max_size = 3
node_group_desired_size = 2
node_group_instance_types = ["t3.small"]
cluster_endpoint_private_access = false
tags = {
  Environment = "dev"
  Terraform   = "true"
}
