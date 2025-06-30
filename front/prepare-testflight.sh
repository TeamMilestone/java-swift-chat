#!/bin/bash

# TestFlight 준비 스크립트
# teammilestone 팀 계정용

echo "🚀 TestFlight 준비 스크립트 시작..."

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 설정값
TEAM_ID="YOUR_TEAM_ID" # teammilestone 팀 ID로 변경 필요
BUNDLE_ID="com.teammilestone.chatapp" # 원하는 bundle ID
APP_NAME="ChatApp"
VERSION="1.0.0"
BUILD_NUMBER="1"

echo -e "${YELLOW}현재 설정:${NC}"
echo "Team ID: $TEAM_ID (변경 필요)"
echo "Bundle ID: $BUNDLE_ID"
echo "Version: $VERSION"
echo "Build: $BUILD_NUMBER"
echo ""

# 1. Xcode 프로젝트 설정 업데이트
echo -e "${GREEN}1. Xcode 프로젝트 설정 업데이트 중...${NC}"

# pbxproj 파일 백업
cp ChatApp.xcodeproj/project.pbxproj ChatApp.xcodeproj/project.pbxproj.backup

# Bundle Identifier 업데이트
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com.example.ChatApp;/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID;/g" ChatApp.xcodeproj/project.pbxproj

# Version 업데이트
sed -i '' "s/MARKETING_VERSION = 1.0;/MARKETING_VERSION = $VERSION;/g" ChatApp.xcodeproj/project.pbxproj

# Build Number 업데이트
sed -i '' "s/CURRENT_PROJECT_VERSION = 1;/CURRENT_PROJECT_VERSION = $BUILD_NUMBER;/g" ChatApp.xcodeproj/project.pbxproj

echo -e "${GREEN}✓ 프로젝트 설정 업데이트 완료${NC}"

# 2. Info.plist 업데이트
echo -e "${GREEN}2. Info.plist 업데이트 중...${NC}"

# Info.plist 백업
cp ChatApp/Info.plist ChatApp/Info.plist.backup

# Info.plist에 필수 키 추가
cat > ChatApp/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundleDisplayName</key>
    <string>ChatApp</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleVersion</key>
    <string>$(CURRENT_PROJECT_VERSION)</string>
    <key>CFBundleShortVersionString</key>
    <string>$(MARKETING_VERSION)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
    </dict>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>armv7</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
        <key>NSExceptionDomains</key>
        <dict>
            <key>chat.team-milestone.click</key>
            <dict>
                <key>NSExceptionAllowsInsecureHTTPLoads</key>
                <true/>
                <key>NSIncludesSubdomains</key>
                <true/>
            </dict>
        </dict>
    </dict>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>프로필 사진을 설정하기 위해 사진 접근 권한이 필요합니다.</string>
    <key>ITSAppUsesNonExemptEncryption</key>
    <false/>
</dict>
</plist>
EOF

echo -e "${GREEN}✓ Info.plist 업데이트 완료${NC}"

# 3. Production URL 설정 파일 생성
echo -e "${GREEN}3. Production 설정 파일 생성 중...${NC}"

cat > ChatApp/Config.swift << 'EOF'
//
//  Config.swift
//  ChatApp
//
//  Configuration for different environments
//

import Foundation

struct Config {
    static let isProduction = true
    
    static var baseURL: String {
        if isProduction {
            return "https://chat.team-milestone.click"
        } else {
            return "http://localhost:8080"
        }
    }
    
    static var wsURL: String {
        if isProduction {
            return "wss://chat.team-milestone.click/chat"
        } else {
            return "ws://localhost:8080/chat"
        }
    }
}
EOF

echo -e "${GREEN}✓ Config.swift 생성 완료${NC}"

# 4. 서비스 파일들을 Config 사용하도록 업데이트하는 스크립트
echo -e "${GREEN}4. 서비스 URL 업데이트 스크립트 생성 중...${NC}"

cat > update-service-urls.sh << 'SCRIPT'
#!/bin/bash

# AuthService.swift 업데이트
sed -i '' 's|"http://localhost:8080|"\(Config.baseURL) + "|g' ChatApp/Services/AuthService.swift

# ChatAPIService.swift 업데이트
sed -i '' 's|"http://localhost:8080|"\(Config.baseURL) + "|g' ChatApp/Services/ChatAPIService.swift

# WebSocketService.swift 업데이트
sed -i '' 's|"ws://localhost:8080/chat"|Config.wsURL|g' ChatApp/Services/WebSocketService.swift

echo "서비스 URL 업데이트 완료!"
SCRIPT

chmod +x update-service-urls.sh

echo -e "${GREEN}✓ URL 업데이트 스크립트 생성 완료${NC}"

# 5. Archive 스킴 생성 안내
echo -e "${YELLOW}\n5. Xcode에서 수행할 작업:${NC}"
echo "1. Xcode에서 프로젝트 열기"
echo "2. ChatApp 타겟 선택 > Signing & Capabilities"
echo "3. Team을 'teammilestone'로 변경"
echo "4. Bundle Identifier가 '$BUNDLE_ID'인지 확인"
echo "5. Automatically manage signing 체크"

# 6. TestFlight 업로드 안내
echo -e "${YELLOW}\n6. TestFlight 업로드 절차:${NC}"
echo "1. 실제 서버 URL로 Config.swift 수정"
echo "2. ./update-service-urls.sh 실행하여 서비스 URL 업데이트"
echo "3. Xcode에서 Generic iOS Device 선택"
echo "4. Product > Archive 실행"
echo "5. Organizer에서 Distribute App 선택"
echo "6. App Store Connect 선택 > Upload"
echo "7. App Store Connect에서 TestFlight 빌드 확인"

echo -e "${RED}\n⚠️  중요 사항:${NC}"
echo "- Team ID를 실제 teammilestone 팀 ID로 변경 필요"
echo "- 서버 도메인을 실제 운영 서버로 변경 필요"
echo "- App Store Connect에 앱이 생성되어 있어야 함"
echo "- 필요한 인증서와 프로비저닝 프로파일이 있어야 함"

echo -e "${GREEN}\n✅ 준비 스크립트 완료!${NC}"