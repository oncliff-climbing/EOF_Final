# AWS 제공자 설정
provider "aws" {
  region = var.region  # 사용할 AWS 리전 설정
}

# VPC 모듈 설정
module "vpc" {
  source = "./modules/vpc"  # VPC 모듈의 소스 경로

  # VPC 및 서브넷 설정 변수
  vpc_cidr_block            = var.vpc_cidr_block
  vpc_name                  = "EOF-vpc"
  public_subnet_a_cidr      = var.public_subnet_a_cidr
  public_subnet_a_name      = "EOF-public-a"
  public_subnet_a_az        = "ap-northeast-1a"
  public_subnet_c_cidr      = var.public_subnet_c_cidr
  public_subnet_c_name      = "EOF-public-c"
  public_subnet_c_az        = "ap-northeast-1c"
  private_subnet_a_cidr     = var.private_subnet_a_cidr
  private_subnet_a_name     = "EOF-private-a"
  private_subnet_a_az       = "ap-northeast-1a"
  private_subnet_c_cidr     = var.private_subnet_c_cidr
  private_subnet_c_name     = "EOF-private-c"
  private_subnet_c_az       = "ap-northeast-1c"
  internet_gateway_name     = "EOF-internet-gateway"
  public_route_table_name   = "EOF-public-route-table"
  nat_gateway_name          = "EOF-NAT-gateway"
  private_route_table_name  = "EOF-private-route-table"
}

# IAM 모듈 설정
module "iam" {
  source = "./modules/iam"  # IAM 모듈의 소스 경로
  tags   = var.tags  # 태그 설정
}

# EKS 모듈 설정
module "eks" {
  source = "./modules/eks"  # EKS 모듈의 소스 경로

  # EKS 클러스터 설정 변수
  cluster_name                      = var.cluster_name
  kubernetes_version                = var.kubernetes_version
  vpc_id                            = module.vpc.vpc_id
  subnet_ids                        = module.vpc.private_subnet_ids
  node_group_min_size               = var.node_group_min_size
  node_group_max_size               = var.node_group_max_size
  node_group_desired_size           = var.node_group_desired_size
  node_group_instance_types         = var.node_group_instance_types
  tags                              = var.tags
  cluster_endpoint_private_access   = var.cluster_endpoint_private_access
  cluster_endpoint_public_access    = var.cluster_endpoint_public_access
}

# EKS 클러스터 데이터 소스 설정
data "aws_eks_cluster" "k8s" {
  name = module.eks.cluster_id  # EKS 클러스터 ID
}

data "aws_eks_cluster_auth" "k8s" {
  name = module.eks.cluster_id  # EKS 클러스터 ID
}

# EKS 클러스터 프로비저닝 후 지연 리소스 설정
resource "null_resource" "delay_k8s_provider" {
  depends_on = [module.eks]  # EKS 모듈 생성 후 실행

  provisioner "local-exec" {
    command = <<EOT
      aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_id}
      kubectl get nodes
    EOT
  }
}

# Kubernetes 제공자 설정
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint  # EKS 클러스터 엔드포인트
  token                  = data.aws_eks_cluster_auth.k8s.token  # EKS 클러스터 인증 토큰
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.k8s.certificate_authority[0].data)  # 클러스터 CA 인증서
  config_path            = "~/.kube/config"  # kubeconfig 파일 경로
}

# EKS 클러스터에 HTTP 접근을 허용하는 보안 그룹 규칙 생성
resource "aws_security_group_rule" "eks_cluster_add_http_access" {
  security_group_id = module.eks.cluster_security_group_id  # EKS 클러스터 보안 그룹 ID
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# EKS 클러스터에 HTTPS 접근을 허용하는 보안 그룹 규칙 생성
resource "aws_security_group_rule" "eks_cluster_add_https_access" {
  security_group_id = module.eks.cluster_security_group_id  # EKS 클러스터 보안 그룹 ID
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# EKS 노드 그룹의 아웃바운드 트래픽을 허용하는 보안 그룹 규칙 생성
resource "aws_security_group_rule" "eks_node_add_egress" {
  security_group_id = module.eks.node_security_group_id  # EKS 노드 그룹 보안 그룹 ID
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ALB 모듈 설정
module "alb" {
  source = "./modules/alb"  # ALB 모듈의 소스 경로

  # ALB 설정 변수
  vpc_id                          = module.vpc.vpc_id
  public_subnet_ids               = module.vpc.public_subnet_ids
  cluster_id                      = module.eks.cluster_id
  region                          = var.region
  alb_sg_name                     = "EOF-AppLB-SG"
  alb_ingress_policy_name         = "AWSLoadBalancerControllerIAMPolicy"
  alb_ingress_policy_file         = "iam_policy.json"
  alb_ingress_role_name           = "alb-ingress-role"
  alb_ingress_service_account_name= "aws-load-balancer-controller"
  app_lb_name                     = "app-loadbalancer"
  app_tg_name                     = "app-target-group"
  app_listener_http_name          = "EOF-App-Listener-HTTP"
  kubeconfig_path                 = "~/.kube/config"
}

# ALB Ingress Controller 서비스 계정 생성
resource "kubernetes_service_account" "alb_ingress_service_account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.alb.alb_ingress_role_arn  # ALB Ingress 역할 ARN
    }
  }

  depends_on = [null_resource.delay_k8s_provider]  # EKS 클러스터 프로비저닝 후 실행
}

# # ALB Ingress Controller 설치
# resource "null_resource" "alb_ingress_controller" {
#   provisioner "local-exec" {
#     command = <<EOT
#       aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_id}
#       sleep 60
#       kubectl get nodes
#       helm repo add eks https://aws.github.io/eks-charts || true
#       helm repo update
#       helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
#         -n kube-system \
#         --set clusterName=${module.eks.cluster_id} \
#         --set serviceAccount.create=false \
#         --set region=${var.region} \
#         --set vpcId=${module.vpc.vpc_id} \
#         --set serviceAccount.name=${var.alb_ingress_service_account_name}
#     EOT
#     environment = {
#       KUBECONFIG = "~/.kube/config"
#     }
#   }

#   depends_on = [
#     kubernetes_service_account.alb_ingress_service_account,
#     module.eks
#   ]
# }
