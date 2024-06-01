# AWS 제공자 설정
provider "aws" {
  region = "ap-northeast-1"  # 사용할 AWS 리전 설정
}

# VPC 리소스 생성
resource "aws_vpc" "EOF_vpc" {
  cidr_block           = var.vpc_cidr_block  # VPC의 CIDR 블록
  enable_dns_hostnames = true  # DNS 호스트 이름 활성화
  enable_dns_support   = true  # DNS 지원 활성화
  instance_tenancy     = "default"  # 인스턴스 테넌시 설정 (기본값)
  tags = {
    Name = "EOF-vpc"  # VPC에 할당할 태그
  }
}

# 퍼블릭 서브넷 리소스 생성 (가용 영역 A)
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.EOF_vpc.id  # 연결할 VPC ID
  cidr_block              = var.public_subnet_a_cidr  # 서브넷의 CIDR 블록
  map_public_ip_on_launch = true  # 인스턴스 시작 시 퍼블릭 IP 할당
  availability_zone       = "ap-northeast-1a"  # 서브넷의 가용 영역
  tags = {
    Name = "EOF-public-a"  # 서브넷에 할당할 태그
    "kubernetes.io/role/elb"  = "1"  # Kubernetes ELB 역할 태그
  }
}

# 퍼블릭 서브넷 리소스 생성 (가용 영역 C)
resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.EOF_vpc.id  # 연결할 VPC ID
  cidr_block              = var.public_subnet_c_cidr  # 서브넷의 CIDR 블록
  map_public_ip_on_launch = true  # 인스턴스 시작 시 퍼블릭 IP 할당
  availability_zone       = "ap-northeast-1c"  # 서브넷의 가용 영역
  tags = {
    Name = "EOF-public-c"  # 서브넷에 할당할 태그
    "kubernetes.io/role/elb"   = "1"  # Kubernetes ELB 역할 태그
  }
}

# 프라이빗 서브넷 리소스 생성 (가용 영역 A)
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.EOF_vpc.id  # 연결할 VPC ID
  cidr_block              = var.private_subnet_a_cidr  # 서브넷의 CIDR 블록
  map_public_ip_on_launch = false  # 인스턴스 시작 시 퍼블릭 IP 할당 안 함
  availability_zone       = "ap-northeast-1a"  # 서브넷의 가용 영역
  tags = {
    Name = "EOF-private-a"  # 서브넷에 할당할 태그
    "kubernetes.io/role/internal-elb" = "1"  # Kubernetes 내부 ELB 역할 태그
  }
}

# 프라이빗 서브넷 리소스 생성 (가용 영역 C)
resource "aws_subnet" "private_c" {
  vpc_id                  = aws_vpc.EOF_vpc.id  # 연결할 VPC ID
  cidr_block              = var.private_subnet_c_cidr  # 서브넷의 CIDR 블록
  map_public_ip_on_launch = false  # 인스턴스 시작 시 퍼블릭 IP 할당 안 함
  availability_zone       = "ap-northeast-1c"  # 서브넷의 가용 영역
  tags = {
    Name = "EOF-private-c"  # 서브넷에 할당할 태그
    "kubernetes.io/role/internal-elb" = "1"  # Kubernetes 내부 ELB 역할 태그
  }
}

# 인터넷 게이트웨이 리소스 생성
resource "aws_internet_gateway" "EOF_igw" {
  vpc_id = aws_vpc.EOF_vpc.id  # 연결할 VPC ID
  tags = {
    Name = "EOF-internet-gateway"  # 인터넷 게이트웨이에 할당할 태그
  }
}

# 기본 라우트 테이블 리소스 생성
resource "aws_default_route_table" "public_route_table" {
  default_route_table_id = aws_vpc.EOF_vpc.default_route_table_id  # 기본 라우트 테이블 ID
  tags = {
    Name = "EOF-public-route-table"  # 라우트 테이블에 할당할 태그
  }
}

# 프라이빗 라우트 테이블 리소스 생성
resource "aws_route_table" "EOF_private_route_table" {
  vpc_id = aws_vpc.EOF_vpc.id  # 연결할 VPC ID
  tags = {
    Name = "EOF-private-route-table"  # 라우트 테이블에 할당할 태그
  }
}

# 인터넷 게이트웨이에 대한 경로 리소스 생성
resource "aws_route" "internet_gw_route" {
  route_table_id         = aws_vpc.EOF_vpc.main_route_table_id  # 연결할 라우트 테이블 ID
  destination_cidr_block = "0.0.0.0/0"  # 대상 CIDR 블록 (모든 트래픽)
  gateway_id             = aws_internet_gateway.EOF_igw.id  # 연결할 인터넷 게이트웨이 ID
}

# EIP 리소스 생성
resource "aws_eip" "EOF_NAT_EIP" {
  domain     = "vpc"  # EIP 도메인 설정
  depends_on = [aws_internet_gateway.EOF_igw]  # 인터넷 게이트웨이에 의존
}

# NAT 게이트웨이 리소스 생성
resource "aws_nat_gateway" "EOF_NAT_gateway" {
  allocation_id = aws_eip.EOF_NAT_EIP.id  # 연결할 EIP ID
  subnet_id     = aws_subnet.public_a.id  # 연결할 서브넷 ID
  depends_on    = [aws_internet_gateway.EOF_igw]  # 인터넷 게이트웨이에 의존
  tags = {
    Name = "EOF-NAT-gateway"  # NAT 게이트웨이에 할당할 태그
  }
}

# 프라이빗 라우트에 대한 경로 리소스 생성
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.EOF_private_route_table.id  # 연결할 프라이빗 라우트 테이블 ID
  destination_cidr_block = "0.0.0.0/0"  # 대상 CIDR 블록 (모든 트래픽)
  nat_gateway_id         = aws_nat_gateway.EOF_NAT_gateway.id  # 연결할 NAT 게이트웨이 ID
}

# 퍼블릭 서브넷 A 라우트 테이블 연결 리소스 생성
resource "aws_route_table_association" "public_subneta_association" {
  subnet_id      = aws_subnet.public_a.id  # 연결할 서브넷 ID
  route_table_id = aws_vpc.EOF_vpc.main_route_table_id  # 연결할 라우트 테이블 ID
}

# 퍼블릭 서브넷 C 라우트 테이블 연결 리소스 생성
resource "aws_route_table_association" "public_subnetb_association" {
  subnet_id      = aws_subnet.public_c.id  # 연결할 서브넷 ID
  route_table_id = aws_vpc.EOF_vpc.main_route_table_id  # 연결할 라우트 테이블 ID
}

# 프라이빗 서브넷 A 라우트 테이블 연결 리소스 생성
resource "aws_route_table_association" "private_subneta_association" {
  subnet_id      = aws_subnet.private_a.id  # 연결할 서브넷 ID
  route_table_id = aws_route_table.EOF_private_route_table.id  # 연결할 프라이빗 라우트 테이블 ID
}

# 프라이빗 서브넷 C 라우트 테이블 연결 리소스 생성
resource "aws_route_table_association" "private_subnetb_association" {
  subnet_id      = aws_subnet.private_c.id  # 연결할 서브넷 ID
  route_table_id = aws_route_table.EOF_private_route_table.id  # 연결할 프라이빗 라우트 테이블 ID
}
