#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수: 사용법 출력
usage() {
    echo -e "${YELLOW}사용법:${NC}"
    echo "  ./run-ios-multi.sh [옵션]"
    echo ""
    echo -e "${YELLOW}옵션:${NC}"
    echo "  1       - 1호기만 실행 (iPhone 15 Pro)"
    echo "  2       - 2호기만 실행 (iPhone 15)"
    echo "  both    - 1호기, 2호기 모두 실행 (기본값)"
    echo "  list    - 사용 가능한 시뮬레이터 목록 표시"
    echo ""
    echo -e "${YELLOW}예제:${NC}"
    echo "  ./run-ios-multi.sh          # 두 시뮬레이터 모두 실행"
    echo "  ./run-ios-multi.sh 1        # 1호기만 실행"
    echo "  ./run-ios-multi.sh 2        # 2호기만 실행"
    echo "  ./run-ios-multi.sh both     # 두 시뮬레이터 모두 실행"
}

# 시뮬레이터 목록 표시
list_simulators() {
    echo -e "${YELLOW}사용 가능한 iOS 시뮬레이터:${NC}"
    xcrun simctl list devices available | grep -E "iPhone|iPad"
}

# 시뮬레이터 부팅 및 앱 실행 함수
launch_simulator() {
    local SIMULATOR_NAME=$1
    local SIMULATOR_NUMBER=$2
    local COLOR=$3
    
    echo -e "\n${COLOR}=== ${SIMULATOR_NUMBER}호기: $SIMULATOR_NAME ===${NC}"
    
    # Device ID 찾기
    DEVICE_ID=$(xcrun simctl list devices available | grep "$SIMULATOR_NAME" | grep -E -o "[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}" | head -1)
    
    if [ -z "$DEVICE_ID" ]; then
        echo -e "${RED}에러: $SIMULATOR_NAME 시뮬레이터를 찾을 수 없습니다.${NC}"
        return 1
    fi
    
    echo "Device ID: $DEVICE_ID"
    
    # 시뮬레이터 상태 확인
    DEVICE_STATE=$(xcrun simctl list devices | grep "$DEVICE_ID" | grep -o "(.*)" | sed 's/[()]//g')
    if [ "$DEVICE_STATE" != "Booted" ]; then
        echo -e "${COLOR}시뮬레이터 부팅 중...${NC}"
        xcrun simctl boot "$DEVICE_ID"
        sleep 3
    else
        echo -e "${COLOR}시뮬레이터가 이미 부팅되어 있습니다${NC}"
    fi
    
    # 빌드 디렉토리 설정 (각 시뮬레이터별로 다른 경로)
    BUILD_DIR="build-sim${SIMULATOR_NUMBER}"
    
    # 프로젝트 빌드
    echo -e "${COLOR}프로젝트 빌드 중...${NC}"
    xcodebuild -project ChatApp.xcodeproj \
        -scheme ChatApp \
        -configuration Debug \
        -destination "platform=iOS Simulator,id=$DEVICE_ID" \
        -derivedDataPath "$BUILD_DIR" \
        build
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}빌드 실패!${NC}"
        return 1
    fi
    
    # 앱 설치
    echo -e "${COLOR}앱 설치 중...${NC}"
    APP_PATH=$(find "$BUILD_DIR/Build/Products" -name "*.app" -type d | head -1)
    
    if [ -z "$APP_PATH" ]; then
        echo -e "${RED}에러: 빌드된 앱을 찾을 수 없습니다.${NC}"
        return 1
    fi
    
    xcrun simctl install "$DEVICE_ID" "$APP_PATH"
    
    # 앱 실행
    echo -e "${COLOR}앱 실행 중...${NC}"
    BUNDLE_ID=$(plutil -extract CFBundleIdentifier raw "$APP_PATH/Info.plist")
    xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"
    
    echo -e "${GREEN}✅ ${SIMULATOR_NUMBER}호기 실행 완료!${NC}"
    
    # 로그 명령어 출력
    echo -e "${YELLOW}${SIMULATOR_NUMBER}호기 로그 보기:${NC}"
    echo "xcrun simctl spawn $DEVICE_ID log stream --predicate 'subsystem == \"$BUNDLE_ID\"'"
    echo ""
}

# 메인 스크립트
echo -e "${GREEN}iOS Chat App 멀티 시뮬레이터 실행 스크립트${NC}"
echo "=============================================="

# 파라미터 처리
OPTION=${1:-both}

case $OPTION in
    list)
        list_simulators
        exit 0
        ;;
    1)
        echo -e "${BLUE}1호기만 실행합니다${NC}"
        # Simulator 앱 열기
        open -a Simulator
        launch_simulator "iPhone 15 Pro" "1" "$BLUE"
        ;;
    2)
        echo -e "${GREEN}2호기만 실행합니다${NC}"
        # Simulator 앱 열기
        open -a Simulator
        launch_simulator "iPhone 15" "2" "$GREEN"
        ;;
    both)
        echo -e "${YELLOW}1호기와 2호기 모두 실행합니다${NC}"
        # Simulator 앱 열기
        open -a Simulator
        
        # 1호기 실행
        launch_simulator "iPhone 15 Pro" "1" "$BLUE"
        
        # 2호기 실행
        launch_simulator "iPhone 15" "2" "$GREEN"
        
        echo -e "\n${GREEN}🎉 모든 시뮬레이터가 실행되었습니다!${NC}"
        echo -e "${YELLOW}이제 각각 다른 계정으로 로그인하여 채팅을 테스트할 수 있습니다.${NC}"
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        echo -e "${RED}잘못된 옵션: $OPTION${NC}"
        usage
        exit 1
        ;;
esac

# 시뮬레이터 위치 조정 팁
if [ "$OPTION" = "both" ]; then
    echo -e "\n${YELLOW}💡 팁: 시뮬레이터 창 정리${NC}"
    echo "1. Simulator 앱에서 Window > Tile Window to Left/Right 사용"
    echo "2. 또는 각 시뮬레이터를 드래그하여 화면 좌우로 배치"
    echo "3. Device > Rotate로 가로/세로 모드 변경 가능"
fi