# Java Chat Backend 서버 실행 가이드

## 사전 요구사항

- Java 17 이상
- Gradle (또는 프로젝트에 포함된 Gradle Wrapper 사용)

## 실행 방법

### 방법 1: 자동 실행 스크립트 (권장)

```bash
cd back
./run-server.sh         # 개발 모드로 실행
./run-server.sh jar     # JAR 파일로 실행
./run-server.sh build   # 빌드만 수행
./run-server.sh test    # 테스트 실행
./run-server.sh stop    # 서버 중지
```

### 방법 2: 백그라운드 실행

```bash
cd back
./run-server-background.sh start    # 백그라운드에서 시작
./run-server-background.sh status   # 상태 확인
./run-server-background.sh logs     # 로그 보기
./run-server-background.sh stop     # 중지
./run-server-background.sh restart  # 재시작
```

### 방법 3: 수동 실행

```bash
cd back
chmod +x gradlew        # 처음 한 번만
./gradlew build        # 빌드
./gradlew bootRun      # 서버 실행
```

### 방법 4: JAR 파일로 실행

```bash
cd back
./gradlew build
java -jar build/libs/backend-0.0.1-SNAPSHOT.jar
```

### 방법 5: Docker로 실행 (권장)

```bash
cd back
./run-docker.sh build   # 이미지 빌드
./run-docker.sh up      # 컨테이너 실행
./run-docker.sh logs    # 로그 확인
./run-docker.sh down    # 컨테이너 중지
```

또는 docker-compose 직접 사용:
```bash
# 프로덕션 모드
docker-compose up -d

# 개발 모드 (소스 코드 변경 시 자동 재시작)
docker-compose -f docker-compose.dev.yml up
```

## 서버 정보

- **포트**: 8080
- **API Base URL**: http://localhost:8080
- **WebSocket URL**: ws://localhost:8080/ws-chat

## 주요 API 엔드포인트

### 인증
- `POST /api/auth/register` - 회원가입
- `POST /api/auth/login` - 로그인

### 사용자
- `GET /api/users/profile/{userId}` - 프로필 조회
- `PUT /api/users/profile/{userId}` - 프로필 수정

### 친구
- `GET /api/friends/{userId}` - 친구 목록 조회
- `POST /api/friends/add` - 친구 추가

### 채팅
- `GET /api/chat/rooms/{userId}` - 채팅방 목록 조회
- `POST /api/chat/rooms` - 채팅방 생성
- `GET /api/chat/rooms/{roomId}/messages` - 메시지 조회
- `POST /api/chat/send` - 메시지 전송

### 파일 업로드
- `POST /api/files/upload/profile` - 프로필 이미지 업로드

## 데이터베이스

- SQLite 데이터베이스 자동 생성 (chat.db)
- 첫 실행 시 테이블 자동 생성

## Docker 실행 시 장점

- 환경 독립적 실행 (Java 설치 불필요)
- 데이터 영속성 보장 (볼륨 마운트)
- 쉬운 배포 및 관리
- 개발 모드에서 핫 리로드 지원

## 문제 해결

### 포트 충돌 시
application.properties에서 포트 변경:
```properties
server.port=8081
```

### 빌드 실패 시
```bash
./gradlew clean build
```

### 로그 확인
서버 실행 중 콘솔에서 로그 확인 가능

## 개발 모드

개발 중 자동 재시작을 원할 경우:
```bash
./gradlew bootRun --continuous
```