# iOS Chat App 실행 가이드

## 사전 요구사항

- macOS
- Xcode 14.0 이상
- Xcode Command Line Tools

## 실행 방법

### 방법 1: 자동 실행 스크립트 (권장)

```bash
cd front
./run-ios.sh
```

이 스크립트는 다음 작업을 자동으로 수행합니다:
1. iOS 시뮬레이터 부팅 (iPhone 15 Pro)
2. 프로젝트 클린 빌드
3. 시뮬레이터에 앱 설치
4. 앱 실행

### 방법 2: 멀티 시뮬레이터 실행 (채팅 테스트용)

```bash
cd front
./run-ios-multi.sh         # 두 시뮬레이터 모두 실행
./run-ios-multi.sh 1       # 1호기만 실행
./run-ios-multi.sh 2       # 2호기만 실행
./run-ios-multi.sh list    # 사용 가능한 시뮬레이터 목록
```

### 방법 3: 채팅 테스트 자동 환경 구성

```bash
cd front
./run-chat-test.sh
```

백엔드 서버 확인 후 시뮬레이터 2대를 자동으로 실행합니다.

### 방법 4: 간단한 빌드 스크립트

```bash
cd front
./run-ios-simple.sh
```

### 방법 5: Xcode에서 실행

1. Xcode에서 `ChatApp.xcodeproj` 열기
2. 상단의 디바이스 선택에서 원하는 시뮬레이터 선택
3. ▶️ 버튼 클릭 또는 `Cmd + R`

### 방법 6: 수동 명령어

```bash
cd front

# 시뮬레이터 부팅
xcrun simctl boot "iPhone 15 Pro"

# Simulator 앱 열기
open -a Simulator

# 빌드 및 실행
xcodebuild -project ChatApp.xcodeproj \
    -scheme ChatApp \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
    -configuration Debug \
    build
```

## 시뮬레이터 선택

다른 시뮬레이터를 사용하려면:

1. 사용 가능한 시뮬레이터 확인:
```bash
xcrun simctl list devices available
```

2. `run-ios.sh` 파일에서 `DEFAULT_SIMULATOR` 변수 수정

## 서버 연결 설정

앱은 기본적으로 `http://localhost:8080`의 백엔드 서버에 연결됩니다.

### 실제 디바이스 테스트 시
1. `ChatApp/Services/AuthService.swift`에서 `baseURL` 수정
2. Mac의 IP 주소로 변경 (예: `http://192.168.1.100:8080`)

## 문제 해결

### 빌드 실패 시
```bash
# DerivedData 삭제
rm -rf ~/Library/Developer/Xcode/DerivedData

# 클린 빌드
xcodebuild clean
```

### 시뮬레이터 문제
```bash
# 모든 시뮬레이터 종료
xcrun simctl shutdown all

# 특정 시뮬레이터 삭제 및 재생성
xcrun simctl delete [Device ID]
xcrun simctl create "iPhone 15 Pro" com.apple.CoreSimulator.SimDeviceType.iPhone-15-Pro
```

### 로그 확인
```bash
# 앱 로그 실시간 확인
xcrun simctl spawn booted log stream --predicate 'subsystem == "com.yourcompany.ChatApp"'
```

## 채팅 테스트

### 테스트 계정
- a@a / 111222
- b@b / 111222

### 멀티 시뮬레이터로 채팅 테스트
1. `./run-ios-multi.sh both` 실행
2. 1호기에서 user1로 로그인
3. 2호기에서 user2로 로그인
4. 친구 추가 및 채팅방 생성
5. 실시간 메시지 테스트

## 개발 팁

- SwiftUI Preview는 Xcode에서 `Cmd + Option + P`로 활성화
- 네트워크 요청은 Console 앱이나 Xcode 디버거에서 확인 가능
- WebSocket 연결 문제는 `WebSocketDebugView`에서 디버깅 가능
- 시뮬레이터 2대 실행 시 Window > Tile Window 기능으로 화면 분할 가능