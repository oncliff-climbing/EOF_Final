# 베이스 이미지 설정
FROM node:14-alpine

# 작업 디렉토리 생성
WORKDIR /app

# package.json 및 package-lock.json 복사
COPY package*.json ./

# 의존성 설치
RUN npm install

# 소스코드 복사
COPY . .

# 필요한 모듈 설치
RUN npm install stream-http https-browserify url stream-browserify assert

# React 애플리케이션 빌드
RUN npm run build

# 앱 실행
CMD ["npm", "start"]
