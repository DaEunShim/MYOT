# --- 1단계: 빌드 스테이지 ---
FROM node:18-slim AS builder

WORKDIR /app

# 의존성 정의 파일 복사
COPY package*.json ./
COPY tsconfig.json ./

# 의존성 설치 (개발용 의존성 포함)
RUN npm install

# 소스 코드 복사
COPY . .

# TypeScript를 JavaScript로 컴파일
# (package.json의 scripts에 "build": "tsc"가 있어야 합니다)
RUN npm run build

# --- 2단계: 실행 스테이지 ---
FROM node:18-slim

WORKDIR /app

# 실행에 필요한 package.json과 production 의존성만 설치
COPY package*.json ./
RUN npm install --only=production

# 1단계에서 빌드된 결과물(dist 또는 build 폴더)만 복사
# (tsconfig.json의 outDir 설정에 따라 dist를 build 등으로 바꿀 수 있습니다)
COPY --from=builder /app/dist ./dist

# 포트 설정 (Cloud Run 기본 포트)
ENV PORT=8080
EXPOSE 8080

# 최종 실행 명령 (빌드된 js 파일 실행)
CMD ["node", "dist/index.js"]
