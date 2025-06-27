# Java-Swift Chat Application

Java Spring Boot 백엔드와 Swift iOS 프론트엔드로 구성된 실시간 채팅 애플리케이션입니다.

## 🚀 주요 기능

- WebSocket 기반 실시간 메시징
- 사용자 인증 및 프로필 관리
- 친구 추가 및 관리
- 채팅방 생성 및 메시지 전송
- 프로필 이미지 업로드
- SQLite 데이터베이스

## 📁 프로젝트 구조

```
java-swift-chat/
├── back/                   # Java Spring Boot 백엔드
│   ├── src/               # 소스 코드
│   ├── Dockerfile         # Docker 설정
│   ├── run-server.sh      # 서버 실행 스크립트
│   └── README.md          # 백엔드 가이드
├── front/                  # Swift iOS 프론트엔드
│   ├── ChatApp/           # iOS 앱 소스 코드
│   ├── run-ios-multi.sh   # 멀티 시뮬레이터 실행
│   └── README.md          # 프론트엔드 가이드
└── docker-compose.yml      # Docker Compose 설정
```

## 🛠 기술 스택

### Backend
- Java 17
- Spring Boot 2.7.0
- Spring WebSocket
- Spring Data JPA
- SQLite
- Docker

### Frontend
- Swift 5
- SwiftUI
- Starscream (WebSocket)
- iOS 15+

## 🚀 빠른 시작

### 1. 백엔드 서버 실행

#### Docker로 실행 (권장)
```bash
cd back
./run-docker.sh up
```

#### 로컬에서 실행
```bash
cd back
./run-server.sh
```

### 2. iOS 앱 실행

#### 멀티 시뮬레이터로 채팅 테스트
```bash
cd front
./run-ios-multi.sh both
```

#### 단일 시뮬레이터 실행
```bash
cd front
./run-ios.sh
```

### 3. 통합 테스트 환경
```bash
cd front
./run-chat-test.sh
```
백엔드 서버 확인 후 시뮬레이터 2대를 자동으로 실행합니다.

## 📱 테스트 계정

- a@a / 111222
- b@b / 111222

## 📖 상세 문서

- [백엔드 실행 가이드](back/README.md)
- [프론트엔드 실행 가이드](front/README.md)

## 🐳 Docker 사용

### Docker 설정 파일들

1. **`Dockerfile`** - 프로덕션용
   - 멀티 스테이지 빌드로 최적화
   - SQLite 포함
   - 볼륨 마운트로 데이터 영속성

2. **`Dockerfile.dev`** - 개발용
   - 소스 코드 마운트로 핫 리로드
   - 빠른 개발 환경 구성

3. **`docker-compose.yml`** - 프로덕션 설정
   - 헬스체크 포함
   - 자동 재시작 설정

4. **`docker-compose.dev.yml`** - 개발 환경 설정
   - 소스 코드 실시간 반영
   - Gradle 캐시로 빌드 속도 향상

5. **`run-docker.sh`** - Docker 관리 스크립트

### Docker 실행 방법

#### 스크립트 사용 (권장)
```bash
cd back
./run-docker.sh build   # 이미지 빌드
./run-docker.sh up      # 서버 실행
./run-docker.sh logs    # 로그 확인
./run-docker.sh status  # 상태 확인
./run-docker.sh down    # 서버 중지
./run-docker.sh shell   # 컨테이너 쉘 접속
./run-docker.sh clean   # 모든 리소스 정리
```

#### Docker Compose 직접 사용

프로덕션 모드:
```bash
docker-compose up -d
```

개발 모드 (핫 리로드):
```bash
docker-compose -f docker-compose.dev.yml up
```

### Docker 사용 시 장점

- **환경 독립적**: Java 설치 불필요
- **데이터 영속성**: 볼륨 마운트로 데이터 보존
- **쉬운 배포**: 어디서든 동일한 환경
- **개발 편의성**: 핫 리로드 지원

## 🌐 API 엔드포인트

- Base URL: `http://localhost:8080`
- WebSocket: `ws://localhost:8080/ws-chat`

주요 엔드포인트:
- `POST /api/auth/login` - 로그인
- `POST /api/auth/register` - 회원가입
- `GET /api/chat/rooms/{userId}` - 채팅방 목록
- `POST /api/chat/send` - 메시지 전송

## 🤝 기여하기

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 있습니다.