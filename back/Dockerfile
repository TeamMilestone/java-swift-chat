# 빌드 단계
FROM gradle:7.6-jdk17 AS build
WORKDIR /app

# Gradle 캐시를 위한 의존성 파일 복사
COPY build.gradle settings.gradle ./
COPY gradle ./gradle

# 의존성 다운로드 (캐시 활용)
RUN gradle dependencies --no-daemon

# 소스 코드 복사 및 빌드
COPY src ./src
RUN gradle build --no-daemon -x test

# 실행 단계
FROM openjdk:17-jdk-slim
WORKDIR /app

# SQLite 설치 (데이터베이스 사용을 위해)
RUN apt-get update && apt-get install -y sqlite3 && rm -rf /var/lib/apt/lists/*

# 빌드된 JAR 파일 복사
COPY --from=build /app/build/libs/*.jar app.jar

# 업로드 디렉토리 생성
RUN mkdir -p /app/uploads

# 데이터베이스 파일을 위한 볼륨
VOLUME ["/app/data", "/app/uploads"]

# 포트 노출
EXPOSE 8080

# 환경 변수 설정
ENV SPRING_PROFILES_ACTIVE=docker

# 실행
ENTRYPOINT ["java", "-jar", "app.jar"]