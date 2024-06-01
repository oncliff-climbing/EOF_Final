region               = "ap-northeast-1"  # 배포할 AWS 리전
availability_zones   = ["ap-northeast-1a", "ap-northeast-1c"]  # 사용할 가용 영역
vpc_cidr_block       = "10.0.0.0/16"  # VPC의 CIDR 블록
public_subnet_a_cidr = "10.0.0.0/24"  # 퍼블릭 서브넷 A의 CIDR 블록
public_subnet_c_cidr = "10.0.1.0/24"  # 퍼블릭 서브넷 C의 CIDR 블록
private_subnet_a_cidr = "10.0.2.0/24"  # 프라이빗 서브넷 A의 CIDR 블록
private_subnet_c_cidr = "10.0.3.0/24"  # 프라이빗 서브넷 C의 CIDR 블록

cluster_name         = "EOF-cluster"  # 클러스터 이름
kubernetes_version   = "1.28"  # 쿠버네티스 버전
node_group_min_size  = 2  # 노드 그룹의 최소 노드 수
node_group_max_size  = 3  # 노드 그룹의 최대 노드 수
node_group_desired_size = 2  # 노드 그룹의 원하는 노드 수
node_group_instance_types = ["t3.small"]  # 노드 그룹의 인스턴스 유형
cluster_endpoint_private_access = false  # 프라이빗 엔드포인트 접근 설정
cluster_endpoint_public_access = true  # 퍼블릭 엔드포인트 접근 설정

tags = {  # 리소스에 적용할 태그
  Environment = "dev"
  Terraform   = "true"
}

alb_ingress_service_account_name = "aws-load-balancer-controller"  # ALB Ingress Controller 서비스 계정 이름
alb_ingress_policy_file          = "iam_policy.json"  # ALB Ingress Controller IAM 정책 파일 경로
