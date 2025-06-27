#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 채팅 테스트 환경 자동 구성${NC}"
echo "======================================"

# 백엔드 서버 확인
check_backend() {
    echo -e "\n${YELLOW}백엔드 서버 상태 확인 중...${NC}"
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 백엔드 서버가 실행 중입니다${NC}"
        return 0
    else
        echo -e "${RED}❌ 백엔드 서버가 실행되지 않았습니다${NC}"
        echo -e "${YELLOW}백엔드 서버를 먼저 실행해주세요:${NC}"
        echo "cd ../back && ./gradlew bootRun"
        return 1
    fi
}

# 메인 실행
echo -e "${CYAN}1단계: 백엔드 서버 확인${NC}"
if ! check_backend; then
    echo -e "\n${YELLOW}백엔드 서버를 실행하시겠습니까? (y/n)${NC}"
    read -r response
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
        echo -e "${GREEN}백엔드 서버를 백그라운드에서 실행합니다...${NC}"
        cd ../back && ./gradlew bootRun > backend.log 2>&1 &
        BACKEND_PID=$!
        echo "백엔드 PID: $BACKEND_PID"
        echo -e "${YELLOW}서버 시작 대기 중... (10초)${NC}"
        sleep 10
        
        if ! check_backend; then
            echo -e "${RED}백엔드 서버 시작 실패. 로그를 확인하세요: back/backend.log${NC}"
            exit 1
        fi
        cd ../front
    else
        echo -e "${RED}백엔드 서버 없이는 채팅 테스트를 진행할 수 없습니다.${NC}"
        exit 1
    fi
fi

echo -e "\n${CYAN}2단계: iOS 시뮬레이터 2대 실행${NC}"
./run-ios-multi.sh both

echo -e "\n${CYAN}=== 채팅 테스트 준비 완료! ===${NC}"
echo -e "${GREEN}테스트 방법:${NC}"
echo "1. 1호기(iPhone 15 Pro)에서 첫 번째 계정으로 로그인"
echo "2. 2호기(iPhone 15)에서 두 번째 계정으로 로그인"
echo "3. 친구 추가 후 채팅방 생성"
echo "4. 메시지 주고받기 테스트"

echo -e "\n${YELLOW}테스트 계정:${NC}"
echo "- user1 / password"
echo "- user2 / password"
echo "- user3 / password"

echo -e "\n${YELLOW}종료 방법:${NC}"
echo "- 시뮬레이터: Simulator 앱 종료"
if [ ! -z "$BACKEND_PID" ]; then
    echo "- 백엔드 서버: kill $BACKEND_PID"
fi

# 로그 모니터링 옵션
echo -e "\n${CYAN}로그 모니터링 (선택사항):${NC}"
echo "백엔드 로그: tail -f ../back/backend.log"
echo "iOS 앱 로그: 각 시뮬레이터별 로그 명령어는 위에 표시됨"