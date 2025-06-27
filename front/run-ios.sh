#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}iOS Chat App 빌드 및 실행 스크립트${NC}"
echo "======================================"

# 1. 사용 가능한 시뮬레이터 목록 표시
echo -e "\n${YELLOW}사용 가능한 iOS 시뮬레이터:${NC}"
xcrun simctl list devices available | grep -E "iPhone|iPad"

# 2. 기본 시뮬레이터 설정 (iPhone 15 Pro)
DEFAULT_SIMULATOR="iPhone 15 Pro"
echo -e "\n${YELLOW}기본 시뮬레이터: $DEFAULT_SIMULATOR${NC}"

# 3. 시뮬레이터 부팅
echo -e "\n${GREEN}시뮬레이터 부팅 중...${NC}"
DEVICE_ID=$(xcrun simctl list devices available | grep "$DEFAULT_SIMULATOR" | grep -E -o "[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}" | head -1)

if [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}에러: $DEFAULT_SIMULATOR 시뮬레이터를 찾을 수 없습니다.${NC}"
    echo "다른 시뮬레이터를 사용하려면 스크립트의 DEFAULT_SIMULATOR 변수를 수정하세요."
    exit 1
fi

echo "Device ID: $DEVICE_ID"

# 시뮬레이터가 이미 부팅되어 있는지 확인
DEVICE_STATE=$(xcrun simctl list devices | grep "$DEVICE_ID" | grep -o "(.*)" | sed 's/[()]//g')
if [ "$DEVICE_STATE" != "Booted" ]; then
    xcrun simctl boot "$DEVICE_ID"
    echo "시뮬레이터 부팅 완료"
else
    echo "시뮬레이터가 이미 부팅되어 있습니다"
fi

# 4. Simulator 앱 열기
echo -e "\n${GREEN}Simulator 앱 실행 중...${NC}"
open -a Simulator

# 5. 프로젝트 빌드
echo -e "\n${GREEN}프로젝트 빌드 중...${NC}"
xcodebuild -project ChatApp.xcodeproj \
    -scheme ChatApp \
    -configuration Debug \
    -destination "platform=iOS Simulator,id=$DEVICE_ID" \
    -derivedDataPath build \
    clean build

if [ $? -ne 0 ]; then
    echo -e "${RED}빌드 실패!${NC}"
    exit 1
fi

echo -e "${GREEN}빌드 성공!${NC}"

# 6. 앱 설치
echo -e "\n${GREEN}앱 설치 중...${NC}"
APP_PATH=$(find build/Build/Products -name "*.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}에러: 빌드된 앱을 찾을 수 없습니다.${NC}"
    exit 1
fi

echo "앱 경로: $APP_PATH"
xcrun simctl install "$DEVICE_ID" "$APP_PATH"

if [ $? -ne 0 ]; then
    echo -e "${RED}설치 실패!${NC}"
    exit 1
fi

echo -e "${GREEN}설치 성공!${NC}"

# 7. 앱 실행
echo -e "\n${GREEN}앱 실행 중...${NC}"
# Bundle ID 추출
BUNDLE_ID=$(plutil -extract CFBundleIdentifier raw "$APP_PATH/Info.plist")
echo "Bundle ID: $BUNDLE_ID"

xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"

if [ $? -ne 0 ]; then
    echo -e "${RED}앱 실행 실패!${NC}"
    exit 1
fi

echo -e "\n${GREEN}✅ 모든 작업이 완료되었습니다!${NC}"
echo -e "${GREEN}앱이 시뮬레이터에서 실행 중입니다.${NC}"

# 8. 로그 확인 옵션
echo -e "\n${YELLOW}팁: 앱 로그를 보려면 새 터미널에서 다음 명령어를 실행하세요:${NC}"
echo "xcrun simctl spawn $DEVICE_ID log stream --predicate 'subsystem == \"$BUNDLE_ID\"'"