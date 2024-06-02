variable "region" {
  description = "The AWS region to create resources in"  # 리소스를 생성할 AWS 리전
  type        = string  # 문자열 타입으로 지정
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"  # VPC의 CIDR 블록
  type        = string  # 문자열 타입으로 지정
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for public subnet A"  # 퍼블릭 서브넷 A의 CIDR 블록
  type        = string  # 문자열 타입으로 지정
}

variable "public_subnet_c_cidr" {
  description = "CIDR block for public subnet C"  # 퍼블릭 서브넷 C의 CIDR 블록
  type        = string  # 문자열 타입으로 지정
}

variable "private_subnet_a_cidr" {
  description = "CIDR block for private subnet A"  # 프라이빗 서브넷 A의 CIDR 블록
  type        = string  # 문자열 타입으로 지정
}

variable "private_subnet_c_cidr" {
  description = "CIDR block for private subnet C"  # 프라이빗 서브넷 C의 CIDR 블록
  type        = string  # 문자열 타입으로 지정
}

variable "cluster_name" {
  description = "Name of the EKS cluster"  # EKS 클러스터의 이름
  type        = string  # 문자열 타입으로 지정
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"  # EKS 클러스터의 Kubernetes 버전
  type        = string  # 문자열 타입으로 지정
}

variable "node_group_min_size" {
  description = "Minimum size of the EKS node group"  # EKS 노드 그룹의 최소 크기
  type        = number  # 숫자 타입으로 지정
}

variable "node_group_max_size" {
  description = "Maximum size of the EKS node group"  # EKS 노드 그룹의 최대 크기
  type        = number  # 숫자 타입으로 지정
}

variable "node_group_desired_size" {
  description = "Desired size of the EKS node group"  # EKS 노드 그룹의 원하는 크기
  type        = number  # 숫자 타입으로 지정
}

variable "node_group_instance_types" {
  description = "Instance types for the EKS node group"  # EKS 노드 그룹에 사용할 인스턴스 타입 목록
  type        = list(string)  # 문자열 리스트 타입으로 지정
}

variable "tags" {
  description = "A map of tags to assign to the resources."  # 리소스에 할당할 태그의 맵
  type        = map(string)  # 문자열 맵 타입으로 지정
  default     = {}  # 기본값 설정 (빈 맵)
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"  # Amazon EKS 프라이빗 API 서버 엔드포인트 활성화 여부
  type        = bool  # 불리언 타입으로 지정
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"  # Amazon EKS 퍼블릭 API 서버 엔드포인트 활성화 여부
  type        = bool  # 불리언 타입으로 지정
}

variable "alb_ingress_service_account_name" {
  description = "The name of the ALB Ingress Controller service account"  # ALB Ingress Controller 서비스 계정의 이름
  type        = string  # 문자열 타입으로 지정
}

variable "alb_ingress_policy_file" {
  description = "The file path for the ALB Ingress Controller IAM policy"  # ALB Ingress Controller IAM 정책 파일 경로
  type        = string  # 문자열 타입으로 지정
}

variable "availability_zones" {
  description = "List of availability zones"  # 가용 영역 목록
  type        = list(string)  # 문자열 리스트 타입으로 지정
}
