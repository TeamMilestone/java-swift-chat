#!/bin/bash

echo "WebSocket 테스트 스크립트"
echo "========================"

# WebSocket 연결 테스트
echo -e "\n1. WebSocket 직접 연결 테스트:"
curl -i -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Host: localhost:8080" \
  -H "Origin: http://localhost:8080" \
  -H "Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==" \
  -H "Sec-WebSocket-Version: 13" \
  http://localhost:8080/ws

echo -e "\n\n2. REST API 테스트 (메시지 전송):"
# 토큰이 필요한 경우 여기에 추가
curl -X POST http://localhost:8080/api/chat/rooms/1/messages \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer dummy-token-1" \
  -d '{
    "senderId": 1,
    "content": "Test message from script"
  }'

echo -e "\n\n3. REST API 테스트 (메시지 조회):"
curl -X GET "http://localhost:8080/api/chat/rooms/1/messages?page=0&size=5" \
  -H "Authorization: Bearer dummy-token-1"

echo -e "\n\n테스트 완료"