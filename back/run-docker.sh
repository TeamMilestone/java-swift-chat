#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}Docker를 이용한 Chat Backend 서버 관리${NC}"
echo "=========================================="

# 함수: 사용법 출력
usage() {
    echo -e "${YELLOW}사용법:${NC}"
    echo "  ./run-docker.sh [명령]"
    echo ""
    echo -e "${YELLOW}명령:${NC}"
    echo "  build   - Docker 이미지 빌드"
    echo "  up      - 컨테이너 실행 (백그라운드)"
    echo "  down    - 컨테이너 중지 및 제거"
    echo "  restart - 컨테이너 재시작"
    echo "  logs    - 컨테이너 로그 확인"
    echo "  status  - 컨테이너 상태 확인"
    echo "  shell   - 컨테이너 내부 쉘 접속"
    echo "  clean   - 모든 이미지 및 볼륨 제거"
    echo ""
    echo -e "${YELLOW}예제:${NC}"
    echo "  ./run-docker.sh build   # 이미지 빌드"
    echo "  ./run-docker.sh up      # 서버 실행"
    echo "  ./run-docker.sh logs    # 로그 확인"
}

# Docker 설치 확인
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker가 설치되어 있지 않습니다.${NC}"
        echo -e "${YELLOW}Docker Desktop을 설치해주세요: https://www.docker.com/products/docker-desktop${NC}"
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker 데몬이 실행되지 않았습니다.${NC}"
        echo -e "${YELLOW}Docker Desktop을 실행해주세요.${NC}"
        return 1
    fi
    
    return 0
}

# Docker 이미지 빌드
build_image() {
    echo -e "${BLUE}Docker 이미지를 빌드합니다...${NC}"
    
    docker build -t chat-backend:latest .
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 이미지 빌드 성공!${NC}"
        docker images | grep chat-backend
    else
        echo -e "${RED}❌ 이미지 빌드 실패!${NC}"
        return 1
    fi
}

# 컨테이너 실행
start_container() {
    echo -e "${GREEN}Docker 컨테이너를 실행합니다...${NC}"
    
    # 이미지가 없으면 먼저 빌드
    if ! docker images | grep -q "chat-backend"; then
        echo -e "${YELLOW}이미지가 없습니다. 먼저 빌드합니다...${NC}"
        build_image
    fi
    
    # docker-compose 사용
    cd ..
    docker-compose up -d
    cd back
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 컨테이너가 시작되었습니다!${NC}"
        echo -e "${BLUE}API URL: http://localhost:8080${NC}"
        echo -e "${BLUE}로그 확인: ./run-docker.sh logs${NC}"
        
        # 헬스체크 대기
        echo -e "${YELLOW}서버 시작 대기 중...${NC}"
        sleep 5
        
        if curl -s http://localhost:8080 > /dev/null 2>&1; then
            echo -e "${GREEN}✅ 서버가 정상적으로 실행 중입니다!${NC}"
        else
            echo -e "${YELLOW}⚠️  서버가 아직 시작 중입니다. 잠시 후 다시 확인해주세요.${NC}"
        fi
    else
        echo -e "${RED}❌ 컨테이너 실행 실패!${NC}"
        return 1
    fi
}

# 컨테이너 중지
stop_container() {
    echo -e "${YELLOW}Docker 컨테이너를 중지합니다...${NC}"
    
    cd ..
    docker-compose down
    cd back
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 컨테이너가 중지되었습니다.${NC}"
    else
        echo -e "${RED}❌ 컨테이너 중지 실패!${NC}"
        return 1
    fi
}

# 컨테이너 재시작
restart_container() {
    echo -e "${CYAN}컨테이너를 재시작합니다...${NC}"
    stop_container
    sleep 2
    start_container
}

# 로그 확인
show_logs() {
    echo -e "${CYAN}컨테이너 로그 (Ctrl+C로 종료):${NC}"
    docker logs -f chat-backend
}

# 컨테이너 상태 확인
check_status() {
    echo -e "${CYAN}Docker 컨테이너 상태:${NC}"
    echo ""
    
    # 컨테이너 상태
    docker ps -a | grep -E "CONTAINER|chat-backend" || echo "chat-backend 컨테이너가 없습니다."
    
    echo ""
    echo -e "${CYAN}Docker 이미지:${NC}"
    docker images | grep -E "REPOSITORY|chat-backend" || echo "chat-backend 이미지가 없습니다."
    
    echo ""
    echo -e "${CYAN}Docker 볼륨:${NC}"
    docker volume ls | grep -E "DRIVER|chat-" || echo "관련 볼륨이 없습니다."
    
    # API 상태 확인
    echo ""
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ API 서버가 응답합니다: http://localhost:8080${NC}"
    else
        echo -e "${YELLOW}⚠️  API 서버가 응답하지 않습니다.${NC}"
    fi
}

# 컨테이너 쉘 접속
enter_shell() {
    echo -e "${CYAN}컨테이너 쉘에 접속합니다...${NC}"
    docker exec -it chat-backend /bin/bash
}

# 모든 리소스 정리
clean_all() {
    echo -e "${RED}⚠️  경고: 모든 Docker 리소스를 제거합니다!${NC}"
    echo -e "${YELLOW}데이터베이스와 업로드 파일이 모두 삭제됩니다.${NC}"
    echo -n "계속하시겠습니까? (y/N): "
    read -r response
    
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
        echo -e "${RED}모든 리소스를 제거합니다...${NC}"
        
        # 컨테이너 중지 및 제거
        cd ..
        docker-compose down -v
        cd back
        
        # 이미지 제거
        docker rmi chat-backend:latest 2>/dev/null
        
        echo -e "${GREEN}✅ 정리 완료!${NC}"
    else
        echo -e "${GREEN}취소되었습니다.${NC}"
    fi
}

# 메인 스크립트
if ! check_docker; then
    exit 1
fi

COMMAND=${1:-usage}

case $COMMAND in
    build)
        build_image
        ;;
    up|start)
        start_container
        ;;
    down|stop)
        stop_container
        ;;
    restart)
        restart_container
        ;;
    logs)
        show_logs
        ;;
    status|ps)
        check_status
        ;;
    shell|sh)
        enter_shell
        ;;
    clean)
        clean_all
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