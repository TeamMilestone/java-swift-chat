#!/bin/bash

# AuthService.swift 업데이트
sed -i '' 's|"http://localhost:8080|"\(Config.baseURL) + "|g' ChatApp/Services/AuthService.swift

# ChatAPIService.swift 업데이트
sed -i '' 's|"http://localhost:8080|"\(Config.baseURL) + "|g' ChatApp/Services/ChatAPIService.swift

# WebSocketService.swift 업데이트
sed -i '' 's|"ws://localhost:8080/chat"|Config.wsURL|g' ChatApp/Services/WebSocketService.swift

echo "서비스 URL 업데이트 완료!"
