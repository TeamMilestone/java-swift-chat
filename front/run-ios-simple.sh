#!/bin/bash

# 간단한 빌드 및 실행 스크립트 (한 줄 명령)

echo "🚀 iOS 앱 빌드 및 실행 중..."

# 시뮬레이터에서 빌드하고 실행 (Xcode가 자동으로 시뮬레이터 부팅)
xcodebuild -project ChatApp.xcodeproj \
    -scheme ChatApp \
    -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
    build-for-testing \
    && xcrun simctl launch booted com.yourcompany.ChatApp

# 또는 xcodebuild의 간단한 버전 사용
# open -a Simulator
# xcodebuild -project ChatApp.xcodeproj -scheme ChatApp -destination 'platform=iOS Simulator,name=iPhone 15 Pro' | xcbeautify