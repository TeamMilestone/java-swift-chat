#!/bin/bash

echo "📱 iOS 시뮬레이터 2개 실행 중..."

# 첫 번째 시뮬레이터 부팅
DEVICE_ID_1="C5C05984-BB48-485C-BD18-B211A2424FDF"  # iPhone 16 Pro
echo "첫 번째 시뮬레이터 부팅 중..."
xcrun simctl boot $DEVICE_ID_1 2>/dev/null || echo "이미 부팅됨"

# 두 번째 시뮬레이터 부팅  
DEVICE_ID_2="823E3042-477E-4FDC-B0BC-70DE4538D4BB"  # iPhone 16
echo "두 번째 시뮬레이터 부팅 중..."
xcrun simctl boot $DEVICE_ID_2 2>/dev/null || echo "이미 부팅됨"

# 시뮬레이터 앱 열기
open -a Simulator

echo "✅ 시뮬레이터 2개가 실행되었습니다!"
echo ""
echo "📝 Xcode에서 ChatApp 프로젝트를 열려면:"
echo "   open ChatApp.xcodeproj"
echo ""
echo "또는 Xcode를 직접 열고 프로젝트를 불러오세요."