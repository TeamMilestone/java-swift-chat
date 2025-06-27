#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Java Chat Backend 서버 실행 스크립트${NC}"
echo "========================================"

# 함수: 사용법 출력
usage() {
    echo -e "${YELLOW}사용법:${NC}"
    echo "  ./run-server.sh [옵션]"
    echo ""
    echo -e "${YELLOW}옵션:${NC}"
    echo "  run     - 개발 모드로 서버 실행 (기본값)"
    echo "  build   - 프로젝트 빌드만 수행"
    echo "  jar     - JAR 파일로 서버 실행"
    echo "  clean   - 빌드 파일 정리"
    echo "  test    - 테스트 실행"
    echo "  stop    - 실행 중인 서버 중지"
    echo ""
    echo -e "${YELLOW}예제:${NC}"
    echo "  ./run-server.sh         # 개발 모드로 서버 실행"
    echo "  ./run-server.sh build   # 빌드만 수행"
    echo "  ./run-server.sh jar     # JAR 파일로 실행"
}

# Java 버전 확인
check_java() {
    echo -e "${YELLOW}Java 버전 확인 중...${NC}"
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
        if [ "$JAVA_VERSION" -ge 17 ]; then
            echo -e "${GREEN}✅ Java $JAVA_VERSION 확인됨${NC}"
            return 0
        else
            echo -e "${RED}❌ Java 17 이상이 필요합니다. 현재 버전: $JAVA_VERSION${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Java가 설치되어 있지 않습니다.${NC}"
        return 1
    fi
}

# Gradle wrapper 권한 설정
setup_gradle() {
    if [ ! -x "gradlew" ]; then
        echo -e "${YELLOW}Gradle wrapper 실행 권한 설정 중...${NC}"
        chmod +x gradlew
        echo -e "${GREEN}✅ 권한 설정 완료${NC}"
    fi
}

# 서버 상태 확인
check_server_status() {
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  서버가 이미 8080 포트에서 실행 중입니다.${NC}"
        return 0
    else
        return 1
    fi
}

# 실행 중인 서버 종료
stop_server() {
    echo -e "${YELLOW}실행 중인 서버 확인 중...${NC}"
    
    # Spring Boot 프로세스 찾기
    PIDS=$(ps aux | grep -E "[j]ava.*backend.*\.jar|[g]radlew.*bootRun" | awk '{print $2}')
    
    if [ -n "$PIDS" ]; then
        echo -e "${YELLOW}실행 중인 서버 프로세스 발견:${NC}"
        ps aux | grep -E "[j]ava.*backend.*\.jar|[g]radlew.*bootRun"
        
        echo -e "${RED}프로세스를 종료합니다...${NC}"
        echo $PIDS | xargs kill -9 2>/dev/null
        sleep 2
        echo -e "${GREEN}✅ 서버가 종료되었습니다.${NC}"
    else
        echo -e "${GREEN}실행 중인 서버가 없습니다.${NC}"
    fi
}

# 빌드 수행
build_project() {
    echo -e "${BLUE}프로젝트 빌드 중...${NC}"
    ./gradlew build
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 빌드 성공!${NC}"
        return 0
    else
        echo -e "${RED}❌ 빌드 실패!${NC}"
        return 1
    fi
}

# 개발 모드로 서버 실행
run_dev_mode() {
    echo -e "${GREEN}개발 모드로 서버를 실행합니다...${NC}"
    echo -e "${YELLOW}종료하려면 Ctrl+C를 누르세요.${NC}"
    echo ""
    ./gradlew bootRun
}

# JAR 파일로 서버 실행
run_jar_mode() {
    echo -e "${BLUE}JAR 파일로 서버를 실행합니다...${NC}"
    
    # 빌드 먼저 수행
    if ! build_project; then
        return 1
    fi
    
    # JAR 파일 찾기
    JAR_FILE=$(find build/libs -name "*.jar" -type f | grep -v "plain" | head -1)
    
    if [ -z "$JAR_FILE" ]; then
        echo -e "${RED}❌ JAR 파일을 찾을 수 없습니다.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}JAR 파일: $JAR_FILE${NC}"
    echo -e "${YELLOW}종료하려면 Ctrl+C를 누르세요.${NC}"
    echo ""
    java -jar "$JAR_FILE"
}

# 클린 빌드
clean_build() {
    echo -e "${YELLOW}빌드 파일을 정리합니다...${NC}"
    ./gradlew clean
    echo -e "${GREEN}✅ 정리 완료!${NC}"
}

# 테스트 실행
run_tests() {
    echo -e "${BLUE}테스트를 실행합니다...${NC}"
    ./gradlew test
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 모든 테스트 통과!${NC}"
    else
        echo -e "${RED}❌ 테스트 실패!${NC}"
    fi
}

# 메인 스크립트
# Java 확인
if ! check_java; then
    exit 1
fi

# Gradle 설정
setup_gradle

# 파라미터 처리
OPTION=${1:-run}

case $OPTION in
    run)
        if check_server_status; then
            echo -e "${YELLOW}기존 서버를 종료하고 새로 시작하시겠습니까? (y/n)${NC}"
            read -r response
            if [[ "$response" == "y" || "$response" == "Y" ]]; then
                stop_server
            else
                echo -e "${RED}서버 실행을 취소합니다.${NC}"
                exit 1
            fi
        fi
        run_dev_mode
        ;;
    build)
        build_project
        ;;
    jar)
        if check_server_status; then
            echo -e "${YELLOW}기존 서버를 종료하고 새로 시작하시겠습니까? (y/n)${NC}"
            read -r response
            if [[ "$response" == "y" || "$response" == "Y" ]]; then
                stop_server
            else
                echo -e "${RED}서버 실행을 취소합니다.${NC}"
                exit 1
            fi
        fi
        run_jar_mode
        ;;
    clean)
        clean_build
        ;;
    test)
        run_tests
        ;;
    stop)
        stop_server
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

# 서버 정보 출력 (run 또는 jar 옵션일 때)
if [[ "$OPTION" == "run" || "$OPTION" == "jar" ]]; then
    echo -e "\n${GREEN}=== 서버 정보 ===${NC}"
    echo -e "${BLUE}API Base URL:${NC} http://localhost:8080"
    echo -e "${BLUE}WebSocket URL:${NC} ws://localhost:8080/ws-chat"
    echo -e "${BLUE}Health Check:${NC} http://localhost:8080/actuator/health"
    echo ""
    echo -e "${YELLOW}API 테스트:${NC}"
    echo "curl -X POST http://localhost:8080/api/auth/login -H 'Content-Type: application/json' -d '{\"username\":\"user1\",\"password\":\"password\"}'"
fi