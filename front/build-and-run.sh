#!/bin/bash

# 시뮬레이터 부팅
echo "시뮬레이터 부팅 중..."
xcrun simctl boot "iPhone 16 Pro" || true
xcrun simctl boot "iPhone 16" || true

# 시뮬레이터 열기
echo "시뮬레이터 열기..."
open -a Simulator

# 잠시 대기
sleep 3

# Swift 패키지로 빌드
echo "앱 빌드 중..."
cd "$(dirname "$0")"

# 임시로 간단한 SwiftUI 앱을 직접 실행
swift run

echo "완료!"