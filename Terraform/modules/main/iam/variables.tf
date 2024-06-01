variable "tags" {
  description = "A map of tags to assign to the resources."  # 리소스에 할당할 태그의 맵
  type        = map(string)  # 문자열 맵 타입으로 지정
  default     = {}  # 기본값 설정 (빈 맵)
}
