variable "vpc_id" {
  description = "ID of the VPC"  # 사용할 VPC의 ID
  type        = string  # 문자열 타입으로 지정
}

variable "alb_sg_name" {
  description = "Name of the ALB security group"  # ALB 보안 그룹의 이름
  type        = string  # 문자열 타입으로 지정
}

variable "alb_ingress_policy_name" {
  description = "Name of the ALB ingress policy"  # ALB Ingress 정책의 이름
  type        = string  # 문자열 타입으로 지정
  default     = "AWSLoadBalancerControllerIAMPolicy"  # 기본값 설정
}

variable "alb_ingress_policy_file" {
  description = "The file path to the ALB Ingress Controller IAM policy"  # ALB Ingress Controller IAM 정책 파일의 경로
  type        = string  # 문자열 타입으로 지정
  default     = "iam_policy.json"  # 기본값 설정
}

variable "alb_ingress_role_name" {
  description = "Name of the ALB ingress role"  # ALB Ingress 역할의 이름
  type        = string  # 문자열 타입으로 지정
}

variable "alb_ingress_service_account_name" {
  description = "The name of the ALB Ingress Controller service account"  # ALB Ingress Controller 서비스 계정의 이름
  type        = string  # 문자열 타입으로 지정
  default     = "aws-load-balancer-controller"  # 기본값 설정
}

variable "app_lb_name" {
  description = "Name of the application load balancer"  # 애플리케이션 로드 밸런서의 이름
  type        = string  # 문자열 타입으로 지정
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"  # 퍼블릭 서브넷 ID 목록
  type        = list(string)  # 문자열 리스트 타입으로 지정
}

variable "app_tg_name" {
  description = "Name of the application target group"  # 애플리케이션 타겟 그룹의 이름
  type        = string  # 문자열 타입으로 지정
}

variable "app_listener_http_name" {
  description = "Name of the HTTP listener for the application load balancer"  # 애플리케이션 로드 밸런서의 HTTP 리스너 이름
  type        = string  # 문자열 타입으로 지정
}

variable "region" {
  description = "AWS region"  # AWS 리전
  type        = string  # 문자열 타입으로 지정
}

variable "cluster_id" {
  description = "EKS cluster ID"  # EKS 클러스터 ID
  type        = string  # 문자열 타입으로 지정
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"  # kubeconfig 파일 경로
  type        = string  # 문자열 타입으로 지정
}
