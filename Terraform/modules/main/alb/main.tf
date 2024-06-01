resource "aws_security_group" "alb_sg" {
  vpc_id = var.vpc_id  # 사용할 VPC의 ID를 변수로 받아서 설정

  ingress {
    from_port   = 80  # ALB의 HTTP 트래픽을 허용할 시작 포트
    to_port     = 80  # ALB의 HTTP 트래픽을 허용할 끝 포트
    protocol    = "tcp"  # 트래픽에 사용할 프로토콜 (TCP)
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP 주소에서의 접근을 허용
  }

  ingress {
    from_port   = 443  # ALB의 HTTPS 트래픽을 허용할 시작 포트
    to_port     = 443  # ALB의 HTTPS 트래픽을 허용할 끝 포트
    protocol    = "tcp"  # 트래픽에 사용할 프로토콜 (TCP)
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP 주소에서의 접근을 허용
  }

  egress {
    from_port   = 0  # 모든 아웃바운드 트래픽을 허용할 시작 포트
    to_port     = 0  # 모든 아웃바운드 트래픽을 허용할 끝 포트
    protocol    = "-1"  # 모든 프로토콜을 허용
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP 주소로의 접근을 허용
  }

  tags = {
    Name = var.alb_sg_name  # 보안 그룹의 이름을 변수로 받아서 설정
  }
}

resource "aws_iam_policy" "alb_ingress_policy" {
  name        = var.alb_ingress_policy_name  # IAM 정책의 이름을 변수로 받아서 설정
  description = "Policy for ALB Ingress Controller"  # IAM 정책에 대한 설명
  policy      = file(var.alb_ingress_policy_file)  # 정책 문서를 파일에서 읽어옴 (JSON 형식)
}

resource "aws_iam_role" "alb_ingress_role" {
  name = var.alb_ingress_role_name  # IAM 역할의 이름을 변수로 받아서 설정
  assume_role_policy = jsonencode({  # 역할 신뢰 정책을 JSON 형식으로 인코딩
    Version = "2012-10-17"  # 정책 버전
    Statement = [
      {
        Effect = "Allow"  # 정책의 효과를 허용으로 설정
        Principal = {
          Service = "eks.amazonaws.com"  # EKS 서비스가 역할을 가정할 수 있도록 허용
        }
        Action = "sts:AssumeRole"  # 역할을 가정할 수 있는 액션을 설정
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_ingress_role_policy" {
  policy_arn = aws_iam_policy.alb_ingress_policy.arn  # 앞에서 생성한 IAM 정책의 ARN
  role       = aws_iam_role.alb_ingress_role.name  # 앞에서 생성한 IAM 역할의 이름
}

output "alb_ingress_role_arn" {
  value = aws_iam_role.alb_ingress_role.arn  # 생성된 IAM 역할의 ARN을 출력
}
