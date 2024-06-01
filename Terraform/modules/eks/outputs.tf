output "vpc_id" {
  value = aws_vpc.EOF-vpc.id  # VPC ID 출력
}

output "public_subnet_a_id" {
  value = aws_subnet.public-a.id  # 퍼블릭 서브넷 A ID 출력
}

output "public_subnet_c_id" {
  value = aws_subnet.public-c.id  # 퍼블릭 서브넷 C ID 출력
}

output "private_subnet_a_id" {
  value = aws_subnet.private-a.id  # 프라이빗 서브넷 A ID 출력
}

output "private_subnet_c_id" {
  value = aws_subnet.private-c.id  # 프라이빗 서브넷 C ID 출력
}

output "eks_cluster_id" {
  value = module.eks.cluster_id  # EKS 클러스터 ID 출력
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint  # EKS 클러스터 엔드포인트 출력
}

output "eks_cluster_security_group_id" {
  value = module.eks.cluster_security_group_id  # EKS 클러스터 보안 그룹 ID 출력
}
