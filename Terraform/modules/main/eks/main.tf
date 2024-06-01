module "eks" {
  source  = "terraform-aws-modules/eks/aws"  # EKS 모듈의 소스 (Terraform Registry에서 제공)
  version = "18.26.6"  # 사용할 모듈의 버전

  # 클러스터 설정
  cluster_name    = var.cluster_name  # 클러스터 이름을 변수로 설정
  cluster_version = var.kubernetes_version  # Kubernetes 버전을 변수로 설정
  vpc_id          = var.vpc_id  # VPC ID를 변수로 설정
  subnet_ids      = var.subnet_ids  # 서브넷 ID 목록을 변수로 설정

  # EKS 관리 노드 그룹 설정
  eks_managed_node_groups = {
    "EOF_node_group" = {  # 노드 그룹 이름
      min_size       = var.node_group_min_size  # 노드 그룹의 최소 크기
      max_size       = var.node_group_max_size  # 노드 그룹의 최대 크기
      desired_size   = var.node_group_desired_size  # 노드 그룹의 원하는 크기
      instance_types = var.node_group_instance_types  # 사용할 인스턴스 타입 목록
      subnet_ids = var.subnet_ids  # 서브넷 ID 목록을 변수로 설정
    }
  }

  # 노드 보안 그룹 추가 규칙 설정
  node_security_group_additional_rules = {
    ingress_allow_access_from_control_plane = {  # 규칙 이름
      type                          = "ingress"  # 인그레스 트래픽 설정
      protocol                      = "tcp"  # 사용할 프로토콜 (TCP)
      from_port                     = 9443  # 시작 포트
      to_port                       = 9443  # 끝 포트
      source_cluster_security_group = true  # 클러스터 보안 그룹에서의 접근을 허용
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"  # 규칙 설명
    }
  }

  tags = var.tags  # 리소스에 적용할 태그
  cluster_endpoint_private_access = var.cluster_endpoint_private_access  # 클러스터 엔드포인트에 대한 프라이빗 접근 설정
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access  # 클러스터 엔드포인트에 대한 퍼블릭 접근 설정
}

# 출력 변수 설정
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint  # 클러스터 엔드포인트 URL
}

output "cluster_id" {
  value = module.eks.cluster_id  # 클러스터 ID
}

output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id  # 클러스터 보안 그룹 ID
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id  # 노드 보안 그룹 ID
}
