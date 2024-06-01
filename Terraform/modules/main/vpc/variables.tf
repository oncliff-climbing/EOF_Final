variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"  # VPC의 CIDR 블록
  type        = string  # 문자열 타입으로 지정
}

variable "vpc_name" {
  description = "Name of the VPC"  # VPC의 이름
  type        = string  # 문자열 타입으로 지정
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for public subnet A"  # 퍼블릭 서브넷 A의 CIDR 블록
  type        = string  # 문자열 타입으로 지정
}

variable "public_subnet_a_name" {
  description = "Name of public subnet A"  # 퍼블릭 서브넷 A의 이름
  type        = string  # 문자열 타입으로 지정
}

variable "public_subnet_a_az" {
  description = "Availability zone for public subnet A"  # 퍼블릭 서브넷 A의 가용 영역
  type        = string  # 문자열 타입으로 지정
}

variable "public_subnet_c_cidr" {
  description = "CIDR block for public subnet C"  # 퍼블릭 서브넷 C의 CIDR 블록
  type        = string  # 문자열 타입으로 지정
}

variable "public_subnet_c_name" {
  description = "Name of public subnet C"  # 퍼블릭 서브넷 C의 이름
  type        = string  # 문자열 타입으로 지정
}

variable "public_subnet_c_az" {
  description = "Availability zone for public subnet C"  # 퍼블릭 서브넷 C의 가용 영역
  type        = string  # 문자열 타입으로 지정
}

variable "private_subnet_a_cidr" {
  description = "CIDR block for private subnet A"  # 프라이빗 서브넷 A의 CIDR 블록
  type        = string  # 문자열 타입으로 지정
}

variable "private_subnet_a_name" {
  description = "Name of private subnet A"  # 프라이빗 서브넷 A의 이름
  type        = string  # 문자열 타입으로 지정
}

variable "private_subnet_a_az" {
  description = "Availability zone for private subnet A"  # 프라이빗 서브넷 A의 가용 영역
  type        = string  # 문자열 타입으로 지정
}

variable "private_subnet_c_cidr" {
  description = "CIDR block for private subnet C"  # 프라이빗 서브넷 C의 CIDR 블록
  type        = string  # 문자열 타입으로 지정
}

variable "private_subnet_c_name" {
  description = "Name of private subnet C"  # 프라이빗 서브넷 C의 이름
  type        = string  # 문자열 타입으로 지정
}

variable "private_subnet_c_az" {
  description = "Availability zone for private subnet C"  # 프라이빗 서브넷 C의 가용 영역
  type        = string  # 문자열 타입으로 지정
}

variable "internet_gateway_name" {
  description = "Name of the internet gateway"  # 인터넷 게이트웨이의 이름
  type        = string  # 문자열 타입으로 지정
}

variable "public_route_table_name" {
  description = "Name of the public route table"  # 퍼블릭 라우트 테이블의 이름
  type        = string  # 문자열 타입으로 지정
}

variable "nat_gateway_name" {
  description = "Name of the NAT gateway"  # NAT 게이트웨이의 이름
  type        = string  # 문자열 타입으로 지정
}

variable "private_route_table_name" {
  description = "Name of the private route table"  # 프라이빗 라우트 테이블의 이름
  type        = string  # 문자열 타입으로 지정
}
