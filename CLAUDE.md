# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Backend Server (Java Spring Boot)
```bash
# Development
cd back
./run-server.sh         # Run in development mode
./run-server.sh jar     # Build and run JAR
./run-server.sh build   # Build only
./run-server.sh test    # Run tests

# Production with Docker
./run-docker.sh build   # Build Docker image
./run-docker.sh up      # Run container
./run-docker.sh logs    # View logs
./run-docker.sh down    # Stop container

# Direct Gradle commands
./gradlew build         # Build project
./gradlew bootRun       # Run application
./gradlew test          # Run tests
./gradlew clean build   # Clean and rebuild
```

### Frontend Client (Swift iOS)
```bash
# Single simulator
cd front
./run-ios.sh            # Run on iPhone 15 Pro simulator

# Multi-simulator for chat testing
./run-ios-multi.sh both # Run on two simulators
./run-ios-multi.sh 1    # Run only simulator 1
./run-ios-multi.sh 2    # Run only simulator 2

# Full test environment
./run-chat-test.sh      # Checks backend then starts 2 simulators
```

### Test Accounts
- a@a / 111222
- b@b / 111222

## Architecture Overview

### Project Structure
This is a real-time chat application with a Spring Boot backend and Swift iOS frontend. The architecture follows clear separation of concerns:

```
back/                       # Java Spring Boot backend
├── controller/            # REST API endpoints
├── service/              # Business logic
├── repository/           # Data access layer
├── entity/              # JPA entities
├── websocket/           # Real-time communication
└── exception/           # Error handling

front/                     # Swift iOS app
├── Views/               # SwiftUI views
├── ViewModels/         # MVVM view models
├── Models/             # Data models
├── Services/           # API and WebSocket clients
└── Utils/              # Helper utilities
```

### Communication Protocol
The application supports two WebSocket protocols:

1. **Simple WebSocket** (iOS clients): `ws://localhost:8080/chat`
   - Native WebSocket for receiving messages
   - Messages sent via REST API

2. **STOMP over SockJS** (web clients): `ws://localhost:8080/ws`
   - Full bidirectional communication
   - Topic-based messaging

### Key Technical Details

**Backend:**
- Spring Boot 3.3.0 with Java 17
- SQLite database with WAL mode (chat.db)
- File uploads stored in ./uploads directory
- WebSocket for real-time messaging
- REST API for all operations

**Frontend:**
- Swift 5 with SwiftUI (iOS 15+)
- Starscream WebSocket client
- MVVM architecture pattern
- Hardcoded to connect to http://localhost:8080

**Database Schema:**
- Users (id, username, email, password, profile_image)
- Friends (user_id, friend_id, status, created_at)
- ChatRooms (id, name, type, created_at)
- ChatMessages (id, room_id, sender_id, content, timestamp)
- ChatParticipants (room_id, user_id, joined_at)

### Development Workflow

1. **Making API Changes:**
   - Modify controllers in back/src/main/java/com/chatapp/backend/controller/
   - Update corresponding services and repositories
   - Test with: `./run-server.sh test`

2. **Adding WebSocket Features:**
   - Simple WebSocket handler: back/src/main/java/com/chatapp/backend/websocket/SimpleWebSocketHandler.java
   - STOMP config: back/src/main/java/com/chatapp/backend/config/WebSocketConfig.java

3. **iOS Client Updates:**
   - API calls: front/ChatApp/Services/
   - WebSocket: front/ChatApp/Services/WebSocketService.swift
   - Views follow SwiftUI patterns with @StateObject ViewModels

4. **Database Changes:**
   - Modify JPA entities in back/src/main/java/com/chatapp/backend/entity/
   - Database auto-migrates on startup (be careful in production)

### Important Configuration

**Backend (application.properties):**
- Server port: 8080
- Max file size: 10MB
- WebSocket message size: 8192 bytes
- SQLite with foreign keys enabled

**Frontend:**
- Service URLs hardcoded to localhost:8080
- Change in Service files for real device testing

### Docker Deployment
Production uses multi-stage builds with volumes for data persistence. Development mode supports hot reload via source mounting.