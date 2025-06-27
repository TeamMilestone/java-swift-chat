#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

LOG_FILE="server.log"
PID_FILE="server.pid"

echo -e "${CYAN}Java Chat Backend 백그라운드 서버 관리${NC}"
echo "========================================="

# 함수: 사용법 출력
usage() {
    echo -e "${YELLOW}사용법:${NC}"
    echo "  ./run-server-background.sh [명령]"
    echo ""
    echo -e "${YELLOW}명령:${NC}"
    echo "  start   - 백그라운드에서 서버 시작"
    echo "  stop    - 백그라운드 서버 중지"
    echo "  status  - 서버 상태 확인"
    echo "  logs    - 서버 로그 확인 (tail -f)"
    echo "  restart - 서버 재시작"
}

# 서버 상태 확인
check_status() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ 서버가 실행 중입니다 (PID: $PID)${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠️  PID 파일은 있지만 프로세스가 없습니다.${NC}"
            rm -f "$PID_FILE"
            return 1
        fi
    else
        echo -e "${YELLOW}서버가 실행되지 않았습니다.${NC}"
        return 1
    fi
}

# 서버 시작
start_server() {
    if check_status > /dev/null 2>&1; then
        echo -e "${YELLOW}서버가 이미 실행 중입니다.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}백그라운드에서 서버를 시작합니다...${NC}"
    
    # Gradle wrapper 권한 설정
    if [ ! -x "gradlew" ]; then
        chmod +x gradlew
    fi
    
    # 백그라운드에서 실행하고 로그를 파일로 저장
    nohup ./gradlew bootRun > "$LOG_FILE" 2>&1 &
    PID=$!
    echo $PID > "$PID_FILE"
    
    echo -e "${YELLOW}서버 시작 중... (PID: $PID)${NC}"
    sleep 5
    
    # 서버 시작 확인
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 서버가 성공적으로 시작되었습니다!${NC}"
        echo -e "${BLUE}API URL: http://localhost:8080${NC}"
        echo -e "${BLUE}로그 확인: ./run-server-background.sh logs${NC}"
        return 0
    else
        echo -e "${RED}❌ 서버 시작에 실패했습니다. 로그를 확인하세요.${NC}"
        echo -e "${YELLOW}tail -f $LOG_FILE${NC}"
        return 1
    fi
}

# 서버 중지
stop_server() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        echo -e "${YELLOW}서버를 중지합니다... (PID: $PID)${NC}"
        
        # 프로세스와 하위 프로세스 모두 종료
        pkill -TERM -P "$PID" 2>/dev/null
        kill -TERM "$PID" 2>/dev/null
        
        sleep 2
        
        # 강제 종료 필요시
        if ps -p "$PID" > /dev/null 2>&1; then
            echo -e "${YELLOW}강제 종료 중...${NC}"
            pkill -KILL -P "$PID" 2>/dev/null
            kill -KILL "$PID" 2>/dev/null
        fi
        
        rm -f "$PID_FILE"
        echo -e "${GREEN}✅ 서버가 중지되었습니다.${NC}"
    else
        echo -e "${YELLOW}실행 중인 서버가 없습니다.${NC}"
    fi
}

# 로그 확인
show_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo -e "${CYAN}서버 로그 (Ctrl+C로 종료):${NC}"
        tail -f "$LOG_FILE"
    else
        echo -e "${YELLOW}로그 파일이 없습니다.${NC}"
    fi
}

# 서버 재시작
restart_server() {
    echo -e "${CYAN}서버를 재시작합니다...${NC}"
    stop_server
    sleep 2
    start_server
}

# 메인 스크립트
COMMAND=${1:-usage}

case $COMMAND in
    start)
        start_server
        ;;
    stop)
        stop_server
        ;;
    status)
        check_status
        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${CYAN}서버 정보:${NC}"
            echo -e "PID 파일: $PID_FILE"
            echo -e "로그 파일: $LOG_FILE"
            echo -e "API 테스트: curl http://localhost:8080"
        fi
        ;;
    logs)
        show_logs
        ;;
    restart)
        restart_server
        ;;
    -h|--help)
        usage
        ;;
    *)
        echo -e "${RED}잘못된 명령: $COMMAND${NC}"
        usage
        exit 1
        ;;
esac