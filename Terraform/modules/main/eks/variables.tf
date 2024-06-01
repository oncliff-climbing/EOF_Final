variable "cluster_name" {
  description = "Name of the EKS cluster"  # EKS 클러스터의 이름
  type        = string  # 문자열 타입으로 지정
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"  # EKS 클러스터의 Kubernetes 버전
  type        = string  # 문자열 타입으로 지정
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"  # EKS 클러스터에 사용할 VPC ID
  type        = string  # 문자열 타입으로 지정
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"  # EKS 클러스터에 사용할 서브넷 ID 목록
  type        = list(string)  # 문자열 리스트 타입으로 지정
}

variable "node_group_min_size" {
  description = "Minimum size of the EKS node group"  # EKS 노드 그룹의 최소 크기
  type        = number  # 숫자 타입으로 지정
  default     = 2  # 기본값 설정
}

variable "node_group_max_size" {
  description = "Maximum size of the EKS node group"  # EKS 노드 그룹의 최대 크기
  type        = number  # 숫자 타입으로 지정
  default     = 3  # 기본값 설정
}

variable "node_group_desired_size" {
  description = "Desired size of the EKS node group"  # EKS 노드 그룹의 원하는 크기
  type        = number  # 숫자 타입으로 지정
  default     = 2  # 기본값 설정
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
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"  # Amazon EKS 프라이빗 API 서버 엔드포인트를 활성화할지 여부
  type        = bool  # 불리언 타입으로 지정
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"  # Amazon EKS 퍼블릭 API 서버 엔드포인트를 활성화할지 여부
  type        = bool  # 불리언 타입으로 지정
}
