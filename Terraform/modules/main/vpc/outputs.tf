# VPC ID 출력
output "vpc_id" {
  value = aws_vpc.EOF_vpc.id  # 생성된 VPC의 ID를 출력
}

# 퍼블릭 서브넷 ID 목록 출력
output "public_subnet_ids" {
  value = [aws_subnet.public_a.id, aws_subnet.public_c.id]  # 생성된 퍼블릭 서브넷의 ID 목록을 출력
}

# 프라이빗 서브넷 ID 목록 출력
output "private_subnet_ids" {
  value = [aws_subnet.private_a.id, aws_subnet.private_c.id]  # 생성된 프라이빗 서브넷의 ID 목록을 출력
}
