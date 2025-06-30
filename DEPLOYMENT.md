# Deployment Guide

이 문서는 다른 PC에서 저장소를 클론하여 배포하는 방법을 설명합니다.

## 서버 배포 (Backend)

서버 배포는 모든 필요한 파일이 저장소에 포함되어 있어 바로 가능합니다.

### 1. 저장소 클론
```bash
git clone https://github.com/TeamMilestone/java-swift-chat.git
cd java-swift-chat
```

### 2. Docker를 사용한 배포
```bash
cd back
./run-docker.sh build   # Docker 이미지 빌드
./run-docker.sh up      # 컨테이너 실행
```

### 3. SSL 설정 (선택사항)
```bash
cd deploy
./setup-ssl.sh          # Let's Encrypt SSL 인증서 자동 발급
```

### 주의사항
- SQLite 데이터베이스는 자동으로 생성됩니다
- 파일 업로드 디렉토리도 자동으로 생성됩니다
- 현재는 개발용 인증 토큰을 사용하므로 프로덕션에서는 JWT 구현 필요

## iOS 앱 배포 (TestFlight)

iOS 앱 배포는 Apple 개발자 계정과 추가 설정이 필요합니다.

### 사전 준비사항

1. **Apple Developer 계정**
   - 유료 개발자 프로그램 가입 필요 ($99/년)
   - Team ID 확인

2. **Apple Developer Portal에서 생성**
   - App ID 생성 (Bundle ID: `com.teammilestone.chatapp`)
   - iOS Distribution Certificate 생성 및 다운로드
   - App Store Distribution Provisioning Profile 생성 및 다운로드

3. **App Store Connect에서 앱 등록**
   - 새 앱 생성
   - 앱 정보 입력
   - TestFlight 설정

### 배포 절차

1. **저장소 클론**
```bash
git clone https://github.com/TeamMilestone/java-swift-chat.git
cd java-swift-chat/front
```

2. **TestFlight 준비 스크립트 실행**
```bash
./prepare-testflight.sh
```
스크립트 실행 시 `YOUR_TEAM_ID`를 실제 Team ID로 수정 필요

3. **Xcode에서 설정**
   - `ChatApp.xcodeproj` 열기
   - Signing & Capabilities에서 Team 선택
   - 다운로드한 Provisioning Profile 적용

4. **Archive 및 업로드**
   - Product > Archive
   - Distribute App > App Store Connect
   - Upload 선택

### 필요한 파일들 (별도 준비)

다음 파일들은 보안상 저장소에 포함되지 않으므로 별도로 준비해야 합니다:

- iOS Distribution Certificate (.cer, .p12)
- Provisioning Profile (.mobileprovision)
- App Store Connect API Key (.p8) - 자동화 시 필요

### 환경 설정

앱은 이미 프로덕션 URL로 설정되어 있습니다:
- API: `https://chat.team-milestone.click`
- WebSocket: `wss://chat.team-milestone.click/chat`

개발 환경으로 변경하려면 `Config.swift`의 `isProduction`을 `false`로 변경하세요.

## 문제 해결

### 서버 배포 문제
- Docker가 설치되어 있는지 확인
- 포트 8080이 사용 중인지 확인
- 로그 확인: `./run-docker.sh logs`

### iOS 배포 문제
- Xcode 버전이 최신인지 확인
- Apple Developer 계정이 활성화되어 있는지 확인
- Bundle ID가 일치하는지 확인
- Provisioning Profile이 유효한지 확인

## 보안 주의사항

다음 파일들은 절대 저장소에 커밋하지 마세요:
- `.mobileprovision` 파일
- `.p12`, `.cer` 인증서 파일
- `.p8` API 키 파일
- `.env` 환경 설정 파일
- JWT 서명 키 파일