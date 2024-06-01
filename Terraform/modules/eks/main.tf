#  AWS 제공자 설정
provider "aws" {
  region = var.region  # 사용할 AWS 리전 설정
}

# VPC 리소스 생성
resource "aws_vpc" "EOF-vpc" {
  cidr_block           = var.vpc_cidr_block  # VPC의 CIDR 블록 설정
  enable_dns_hostnames = true  # DNS 호스트네임 활성화
  enable_dns_support   = true  # DNS 지원 활성화
  instance_tenancy     = "default"  # 인스턴스 테넌시 설정
  tags = {
    Name = "EOF-vpc"  # 태그 설정
  }
}

# 퍼블릭 서브넷 생성
resource "aws_subnet" "public-a" {
  vpc_id                  = aws_vpc.EOF-vpc.id  # VPC ID 참조
  cidr_block              = var.public_subnet_a_cidr  # 서브넷의 CIDR 블록 설정+
  map_public_ip_on_launch = true  # 퍼블릭 IP 자동 할당
  availability_zone       = "ap-northeast-1a"  # 가용 영역 설정
  tags = {
    Name = "EOF-public-a"  # 태그 설정
  }
}

resource "aws_subnet" "public-c" {
  vpc_id                  = aws_vpc.EOF-vpc.id  # VPC ID 참조
  cidr_block              = var.public_subnet_c_cidr  # 서브넷의 CIDR 블록 설정
  map_public_ip_on_launch = true  # 퍼블릭 IP 자동 할당
  availability_zone       = "ap-northeast-1c"  # 가용 영역 설정
  tags = {
    Name = "EOF-public-c"  # 태그 설정
  }
}

# 프라이빗 서브넷 생성
resource "aws_subnet" "private-a" {
  vpc_id                  = aws_vpc.EOF-vpc.id  # VPC ID 참조
  cidr_block              = var.private_subnet_a_cidr  # 서브넷의 CIDR 블록 설정
  map_public_ip_on_launch = true  # 퍼블릭 IP 자동 할당
  availability_zone       = "ap-northeast-1a"  # 가용 영역 설정
  tags = {
    Name = "EOF-private-a"  # 태그 설정
  }
}

resource "aws_subnet" "private-c" {
  vpc_id                  = aws_vpc.EOF-vpc.id  # VPC ID 참조
  cidr_block              = var.private_subnet_c_cidr  # 서브넷의 CIDR 블록 설정
  map_public_ip_on_launch = true  # 퍼블릭 IP 자동 할당
  availability_zone       = "ap-northeast-1c"  # 가용 영역 설정
  tags = {
    Name = "EOF-private-c"  # 태그 설정
  }  
}

# 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "EOF-igw" {
  vpc_id = aws_vpc.EOF-vpc.id  # VPC ID 참조
  tags = {
    Name = "EOF-internet-gateway"  # 태그 설정
  }
}

# 기본 라우팅 테이블 태그 설정
resource "aws_default_route_table" "public-route_table" {
  default_route_table_id = aws_vpc.EOF-vpc.default_route_table_id  # 기본 라우팅 테이블 ID 참조
  tags = {
    Name = "EOF-public-route-table"  # 태그 설정
  }
}

# 인터넷 게이트웨이를 사용하는 라우트 설정
resource "aws_route" "internet-gw-route" {
  route_table_id         = aws_vpc.EOF-vpc.main_route_table_id  # 라우팅 테이블 ID 참조
  destination_cidr_block = "0.0.0.0/0"  # 기본 라우트 설정
  gateway_id             = aws_internet_gateway.EOF-igw.id  # 인터넷 게이트웨이 ID 참조
}

# EIP(Elastic IP) 생성
resource "aws_eip" "EOF-NAT-EIP" {
  domain     = "vpc"  # VPC 사용 설정
  depends_on = [aws_internet_gateway.EOF-igw]  # 인터넷 게이트웨이 생성 후 실행
}

# NAT 게이트웨이 생성
resource "aws_nat_gateway" "EOF-NAT-gateway" {
  allocation_id = aws_eip.EOF-NAT-EIP.id  # EIP 할당 ID 참조
  subnet_id     = aws_subnet.public-a.id  # 퍼블릭 서브넷 ID 참조
  depends_on    = [aws_internet_gateway.EOF-igw]  # 인터넷 게이트웨이 생성 후 실행
    tags = {
    Name = "EOF-NAT-gateway"  # 태그 설정
  }
}

# 프라이빗 라우팅 테이블 생성
resource "aws_route_table" "EOF-private-route-table" {
  vpc_id = aws_vpc.EOF-vpc.id  # VPC ID 참조
  tags = {
    Name = "EOF-private-route-table"  # 태그 설정
  }
}

# 프라이빗 라우트 설정
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.EOF-private-route-table.id  # 라우팅 테이블 ID 참조
  destination_cidr_block = "0.0.0.0/0"  # 기본 라우트 설정
  nat_gateway_id         = aws_nat_gateway.EOF-NAT-gateway.id  # NAT 게이트웨이 ID 참조
}

# 퍼블릭 서브넷과 라우팅 테이블 연결
resource "aws_route_table_association" "public_subneta_association" {
  subnet_id      = aws_subnet.public-a.id  # 퍼블릭 서브넷 ID 참조
  route_table_id = aws_vpc.EOF-vpc.main_route_table_id  # 라우팅 테이블 ID 참조
}

resource "aws_route_table_association" "public_subnetb_association" {
  subnet_id      = aws_subnet.public-c.id  # 퍼블릭 서브넷 ID 참조
  route_table_id = aws_vpc.EOF-vpc.main_route_table_id  # 라우팅 테이블 ID 참조
}

# 프라이빗 서브넷과 라우팅 테이블 연결
resource "aws_route_table_association" "private_subneta_association" {
  subnet_id      = aws_subnet.private-a.id  # 프라이빗 서브넷 ID 참조
  route_table_id = aws_route_table.EOF-private-route-table.id  # 라우팅 테이블 ID 참조
}

resource "aws_route_table_association" "private_subnetb_association" {
  subnet_id      = aws_subnet.private-c.id  # 프라이빗 서브넷 ID 참조
  route_table_id = aws_route_table.EOF-private-route-table.id  # 라우팅 테이블 ID 참조
}

# EKS 클러스터 모듈 사용
module "eks" {
  source          = "terraform-aws-modules/eks/aws"  # EKS 모듈 소스
  version         = "18.26.6"  # EKS 모듈 버전
  cluster_name    = var.cluster_name  # 클러스터 이름
  cluster_version = var.kubernetes_version  # 쿠버네티스 버전
  vpc_id          = aws_vpc.EOF-vpc.id  # VPC ID 참조
  subnet_ids = [
    aws_subnet.private-a.id,
    aws_subnet.private-c.id
  ]
  eks_managed_node_groups = {
    "EOF_node_group" = {
      min_size       = var.node_group_min_size  # 최소 노드 수
      max_size       = var.node_group_max_size  # 최대 노드 수
      desired_size   = var.node_group_desired_size  # 원하는 노드 수
      instance_types = var.node_group_instance_types  # 인스턴스 유형
    }
  }
  tags = var.tags  # 태그 설정
  cluster_endpoint_private_access = var.cluster_endpoint_private_access  # 프라이빗 엔드포인트 접근 설정
}

# EKS 클러스터 보안 그룹 규칙 추가
resource "aws_security_group_rule" "eks_cluster_add_http_access" {
  security_group_id = module.eks.cluster_security_group_id  # 클러스터 보안 그룹 ID 참조
  type              = "ingress"  # 인그레스 규칙
  from_port         = 80  # 시작 포트 (HTTP)
  to_port           = 80  # 종료 포트 (HTTP)
  protocol          = "tcp"  # TCP 프로토콜
  cidr_blocks       = ["0.0.0.0/0"]  # 허용할 CIDR 블록
}

resource "aws_security_group_rule" "eks_cluster_add_https_access" {
  security_group_id = module.eks.cluster_security_group_id  # 클러스터 보안 그룹 ID 참조
  type              = "ingress"  # 인그레스 규칙
  from_port         = 443  # 시작 포트 (HTTPS)
  to_port           = 443  # 종료 포트 (HTTPS)
  protocol          = "tcp"  # TCP 프로토콜
  cidr_blocks       = ["0.0.0.0/0"]  # 허용할 CIDR 블록
}

# EKS 노드 보안 그룹 규칙 추가
resource "aws_security_group_rule" "eks_node_add_egress" {
  security_group_id = module.eks.node_security_group_id  # 노드 보안 그룹 ID 참조
  type              = "egress"  # 이그레스 규칙
  from_port         = 0  # 시작 포트
  to_port           = 0  # 종료 포트
  protocol          = "-1"  # 모든 프로토콜
  cidr_blocks       = ["0.0.0.0/0"]  # 허용할 CIDR 블록
}

# ALB 보안 그룹 생성
resource "aws_security_group" "alb_sg" {  # 리소스 이름을 일관되게 사용
  vpc_id = aws_vpc.EOF-vpc.id  # VPC ID 참조

  ingress {
    from_port   = 80  # HTTP 포트
    to_port     = 80  # HTTP 포트
    protocol    = "tcp"  # TCP 프로토콜
    cidr_blocks = ["0.0.0.0/0"]  # 허용할 CIDR 블록
  }

  ingress {
    from_port   = 443  # HTTPS 포트
    to_port     = 443  # HTTPS 포트
    protocol    = "tcp"  # TCP 프로토콜
    cidr_blocks = ["0.0.0.0/0"]  # 허용할 CIDR 블록
  }

  egress {
    from_port   = 0  # 시작 포트
    to_port     = 0  # 종료 포트
    protocol    = "-1"  # 모든 프로토콜
    cidr_blocks = ["0.0.0.0/0"]  # 허용할 CIDR 블록
  }

  tags = {
    Name = "EOF-AppLB-SG"  # 태그 설정
  }
}

# ALB 생성
resource "aws_lb" "app_lb" {
  name               = "app-loadbalancer"  # ALB 이름
  internal           = false  # 외부용 ALB
  load_balancer_type = "application"  # ALB 타입
  security_groups    = [aws_security_group.alb_sg.id]  # 보안 그룹 설정
  subnets            = [aws_subnet.public-a.id, aws_subnet.public-c.id]  # 서브넷 설정

  enable_deletion_protection = false  # 삭제 보호 비활성화
  tags = {
    Name = "EOF-App-LB"  # 태그 설정
  }
}

# ALB 타겟 그룹 생성
resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"  # 타겟 그룹 이름
  port     = 80  # 포트 번호
  protocol = "HTTP"  # 프로토콜
  vpc_id   = aws_vpc.EOF-vpc.id  # VPC ID 참조

  tags = {
    Name = "EOF-App-TG"  # 태그 설정
  }
}

# ALB 리스너 생성 (HTTP)
resource "aws_lb_listener" "app_listener_http" {
  load_balancer_arn = aws_lb.app_lb.arn  # ALB ARN 참조
  port              = "80"  # 리스너 포트
  protocol          = "HTTP"  # 프로토콜

  default_action {
    type             = "forward"  # 액션 타입
    target_group_arn = aws_lb_target_group.app_tg.arn  # 타겟 그룹 ARN 참조
  }

  tags = {
    Name = "EOF-App-Listener-HTTP"  # 태그 설정
  }
}
