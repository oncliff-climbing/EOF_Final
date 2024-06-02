resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"  # EKS 클러스터 역할의 이름
  assume_role_policy = jsonencode({  # 역할 신뢰 정책을 JSON 형식으로 인코딩
    Version = "2012-10-17"  # 정책 버전
    Statement = [
      {
        Effect = "Allow"  # 정책의 효과를 허용으로 설정
        Principal = {
          Service = "eks.amazonaws.com"  # EKS 서비스가 역할을 가정할 수 있도록 허용
        }
        Action = "sts:AssumeRole"  # 역할을 가정할 수 있는 액션을 설정
      }
    ]
  })
  tags = var.tags  # 리소스에 적용할 태그
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"  # EKS 클러스터 정책의 ARN
  role       = aws_iam_role.eks_cluster_role.name  # 앞에서 생성한 EKS 클러스터 역할의 이름
}

resource "aws_iam_role_policy_attachment" "eks_service_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"  # EKS 서비스 정책의 ARN
  role       = aws_iam_role.eks_cluster_role.name  # 앞에서 생성한 EKS 클러스터 역할의 이름
}

resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"  # EKS 노드 그룹 역할의 이름
  assume_role_policy = jsonencode({  # 역할 신뢰 정책을 JSON 형식으로 인코딩
    Version = "2012-10-17"  # 정책 버전
    Statement = [
      {
        Effect = "Allow"  # 정책의 효과를 허용으로 설정
        Principal = {
          Service = "ec2.amazonaws.com"  # EC2 서비스가 역할을 가정할 수 있도록 허용
        }
        Action = "sts:AssumeRole"  # 역할을 가정할 수 있는 액션을 설정
      }
    ]
  })
  tags = var.tags  # 리소스에 적용할 태그
}

resource "aws_iam_role_policy_attachment" "eks_node_group_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"  # EKS 워커 노드 정책의 ARN
  role       = aws_iam_role.eks_node_group_role.name  # 앞에서 생성한 EKS 노드 그룹 역할의 이름
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"  # EKS CNI 정책의 ARN
  role       = aws_iam_role.eks_node_group_role.name  # 앞에서 생성한 EKS 노드 그룹 역할의 이름
}

resource "aws_iam_role_policy_attachment" "eks_registry_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"  # Amazon ECR 읽기 전용 정책의 ARN
  role       = aws_iam_role.eks_node_group_role.name  # 앞에서 생성한 EKS 노드 그룹 역할의 이름
}
