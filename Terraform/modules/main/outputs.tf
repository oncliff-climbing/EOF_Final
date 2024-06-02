# VPC ID 출력
output "vpc_id" {
  description = "ID of the VPC"  # VPC의 ID
  value       = module.vpc.vpc_id  # VPC 모듈에서 생성된 VPC ID
}

# 퍼블릭 서브넷 ID 목록 출력
output "public_subnet_ids" {
  description = "IDs of the public subnets"  # 퍼블릭 서브넷의 ID 목록
  value       = module.vpc.public_subnet_ids  # VPC 모듈에서 생성된 퍼블릭 서브넷 ID 목록
}

# 프라이빗 서브넷 ID 목록 출력
output "private_subnet_ids" {
  description = "IDs of the private subnets"  # 프라이빗 서브넷의 ID 목록
  value       = module.vpc.private_subnet_ids  # VPC 모듈에서 생성된 프라이빗 서브넷 ID 목록
}

# EKS 클러스터 ID 출력
output "eks_cluster_id" {
  description = "ID of the EKS cluster"  # EKS 클러스터의 ID
  value       = module.eks.cluster_id  # EKS 모듈에서 생성된 클러스터 ID
}

# EKS 클러스터 엔드포인트 출력
output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster"  # EKS 클러스터의 엔드포인트
  value       = module.eks.cluster_endpoint  # EKS 모듈에서 생성된 클러스터 엔드포인트
}

# EKS 클러스터 보안 그룹 ID 출력
output "eks_cluster_security_group_id" {
  description = "Security group ID of the EKS cluster"  # EKS 클러스터의 보안 그룹 ID
  value       = module.eks.cluster_security_group_id  # EKS 모듈에서 생성된 보안 그룹 ID
}

# EKS 노드 보안 그룹 ID 출력
output "eks_node_security_group_id" {
  description = "Security group ID of the EKS node group"  # EKS 노드 그룹의 보안 그룹 ID
  value       = module.eks.node_security_group_id  # EKS 모듈에서 생성된 노드 보안 그룹 ID
}
