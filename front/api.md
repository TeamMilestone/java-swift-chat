# Chat Application API Documentation

## Base URL
- Development: `http://localhost:8080`

## WebSocket Endpoints

### For iOS (Simple WebSocket)
- **Connection URL**: `ws://localhost:8080/chat`
- **Protocol**: Native WebSocket (not SockJS)
- **Usage**: Real-time message receiving only

### For Web (STOMP/SockJS)
- **Connection URL**: `ws://localhost:8080/ws`
- **Protocol**: STOMP over SockJS
- **Usage**: Full bidirectional communication

## Authentication

### Register
- **POST** `/api/auth/register`
- **Request Body:**
```json
{
  "username": "string (3-20 chars)",
  "password": "string (min 6 chars)",
  "nickname": "string"
}
```
- **Response:**
```json
{
  "user": {
    "id": 1,
    "username": "user123",
    "nickname": "User",
    "profileImageUrl": "/api/files/default.png",
    "lastSeen": "2025-06-26T12:00:00"
  },
  "token": "dummy-token-1"
}
```

### Login
- **POST** `/api/auth/login`
- **Request Body:**
```json
{
  "username": "string",
  "password": "string"
}
```
- **Response:** Same as Register

## User Management

### Upload Profile Image
- **POST** `/api/users/{userId}/profile-image`
- **Form Data:** `file` (multipart/form-data)
- **Response:**
```json
{
  "profileImageUrl": "/api/files/uuid_filename.jpg"
}
```

## Friend Management

### Search Users
- **GET** `/api/friends/search?query={query}&userId={userId}`
- **Parameters:**
  - `query`: Search string that can be:
    - User ID (exact match): `"2"`
    - Username (partial match): `"b@b"` or `"@b"`
    - Nickname (partial match): `"User B"` or `"User"`
  - `userId`: Current user's ID (to exclude from results)
- **Search Examples:**
  - Search by ID: `/api/friends/search?query=2&userId=1`
  - Search by username: `/api/friends/search?query=b@b&userId=1`
  - Search by nickname: `/api/friends/search?query=User%20B&userId=1`
- **Response:**
```json
[
  {
    "id": 2,
    "username": "b@b",
    "nickname": "User B",
    "profileImageUrl": "/api/files/default.png",
    "lastSeen": "2025-06-26T12:00:00"
  }
]
```

### Get Friend List
- **GET** `/api/friends?userId={userId}`
- **Response:**
```json
[
  {
    "id": 2,
    "username": "friend1",
    "nickname": "Friend 1",
    "profileImageUrl": "/api/files/profile1.jpg",
    "lastSeen": "2025-06-26T12:00:00"
  }
]
```

### Add Friend
- **POST** `/api/friends/add`
- **Request Body:**
```json
{
  "userId": 1,
  "friendId": 2
}
```
- **Response:**
```json
{
  "success": true,
  "message": "Friend added successfully"
}
```
- **Note:** 양방향 친구 관계가 생성됩니다. a@a가 b@b를 친구 추가하면, b@b의 친구 목록에도 a@a가 자동으로 추가됩니다.

### Remove Friend (친구 끊기)
- **DELETE** `/api/friends/remove?userId={userId}&friendId={friendId}`
- **Parameters:**
  - `userId`: 친구를 끊는 사용자의 ID
  - `friendId`: 끊을 친구의 ID
- **Example:**
  - a@a(ID: 1)가 b@b(ID: 2)와 친구 끊기: `/api/friends/remove?userId=1&friendId=2`
- **Response:**
```json
{
  "success": true,
  "message": "Friend removed successfully"
}
```
- **Note:** 양방향 친구 관계가 모두 삭제됩니다. a@a가 b@b와 친구를 끊으면, b@b의 친구 목록에서도 a@a가 자동으로 삭제됩니다.

## Chat Operations

### Get User's Chat Rooms
- **GET** `/api/chat/rooms?userId={userId}`
- **Response:**
```json
[
  {
    "id": 1,
    "name": "Chat Room Name",
    "isGroup": false,
    "announcement": "Optional announcement",
    "updatedAt": "2025-06-26T12:00:00",
    "participants": [
      {
        "id": 1,
        "username": "user1",
        "nickname": "User 1",
        "profileImageUrl": "/api/files/profile1.jpg",
        "lastSeen": "2025-06-26T12:00:00"
      }
    ],
    "lastMessage": {
      "id": 1,
      "content": "Last message",
      "senderId": 1,
      "senderName": "User 1",
      "senderProfileImageUrl": "/api/files/profile1.jpg",
      "chatRoomId": 1,
      "sentAt": "2025-06-26T12:00:00",
      "unreadCount": 0
    },
    "unreadCount": 5
  }
]
```

### Create Direct Chat
- **POST** `/api/chat/rooms/direct`
- **Request Body:**
```json
{
  "userId1": 1,
  "userId2": 2
}
```
- **Response:**
```json
{
  "chatRoomId": 1
}
```

### Create Group Chat
- **POST** `/api/chat/rooms/group`
- **Request Body:**
```json
{
  "name": "Group Name",
  "participantIds": [1, 2, 3]
}
```
- **Response:**
```json
{
  "chatRoomId": 2
}
```

### Get Chat Room Messages
- **GET** `/api/chat/rooms/{roomId}/messages?page=0&size=50`
- **Response:**
```json
[
  {
    "id": 1,
    "content": "Message text",
    "senderId": 1,
    "senderName": "User 1",
    "senderProfileImageUrl": "/api/files/profile1.jpg",
    "chatRoomId": 1,
    "sentAt": "2025-06-26T12:00:00",
    "unreadCount": 2
  }
]
```

### Send Message (REST API)
- **POST** `/api/chat/rooms/{roomId}/messages`
- **Request Body:**
```json
{
  "senderId": 1,
  "content": "Hello, this is a message"
}
```
- **Response:**
```json
{
  "id": 123,
  "content": "Hello, this is a message",
  "senderId": 1,
  "senderName": "User A",
  "senderProfileImageUrl": "/api/files/default.png",
  "chatRoomId": 1,
  "sentAt": "2025-06-26T12:00:00",
  "unreadCount": 1
}
```
- **Note:** 메시지는 WebSocket을 통해 실시간으로 다른 참여자들에게 전달됩니다.

### Update Chat Room Announcement
- **PUT** `/api/chat/rooms/{roomId}/announcement`
- **Request Body:**
```json
{
  "announcement": "New announcement text"
}
```
- **Response:**
```json
{
  "success": true
}
```

## iOS WebSocket Usage

### Connection and Subscription
```swift
// 1. Connect to WebSocket
let socket = WebSocket(request: URLRequest(url: URL(string: "ws://localhost:8080/chat")!))

// 2. Subscribe to room
let subscribeMessage = [
    "type": "subscribe",
    "roomId": 1
]
socket.write(string: JSONSerialization.data(withJSONObject: subscribeMessage))

// 3. Handle incoming messages
socket.onEvent = { event in
    case .text(let text):
        // Parse received message JSON
        let messageData = try JSONSerialization.jsonObject(with: text.data(using: .utf8)!)
}
```

### Send Message (Use REST API)
```swift
// Send message via REST API - NOT WebSocket
let url = URL(string: "http://localhost:8080/api/chat/rooms/\(roomId)/messages")!
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")

let body = [
    "senderId": 1,
    "content": "Hello World"
]
request.httpBody = try JSONSerialization.data(withJSONObject: body)

URLSession.shared.dataTask(with: request).resume()
```

## WebSocket Messages (STOMP - for web)

### Send Message
- **Destination:** `/app/chat.send/{roomId}`
- **Payload:**
```json
{
  "senderId": 1,
  "content": "Message text"
}
```
- **Broadcast to:** `/topic/chatroom.{roomId}`
- **Broadcast Format:** MessageDTO (same as Get Messages response)

### Mark Message as Read
- **Destination:** `/app/chat.read/{roomId}`
- **Payload:**
```json
{
  "messageId": 1,
  "userId": 2
}
```

## File Access
- **GET** `/api/files/{fileName}`
- Returns the uploaded file or default.png if not found

## Implementation Notes

1. **Authentication**: Currently using dummy tokens. In production, implement JWT.
2. **WebSocket Connection**: Use SockJS client for iOS compatibility
3. **Profile Images**: Stored locally in `./uploads` directory
4. **Database**: SQLite3 with WAL mode for concurrent reads
5. **Default Profile**: All users start with `default.png` as profile image

## Error Responses
All endpoints return error in format:
```json
{
  "error": "Error message"
}
```

## iOS Client Implementation Tips

1. Use URLSession for REST API calls
2. Use Starscream or similar library for WebSocket/SockJS
3. Store auth token in Keychain
4. Cache profile images locally
5. Implement message pagination for performance
6. Use Core Data or similar for local message storage

## Sample iOS WebSocket Connection

```swift
// Using Starscream library
let request = URLRequest(url: URL(string: "ws://localhost:8080/ws")!)
let webSocket = WebSocket(request: request)

// Subscribe to chat room updates
webSocket.onEvent = { event in
    switch event {
    case .text(let text):
        // Parse JSON message
    case .connected:
        // Subscribe to topics
    default:
        break
    }
}

webSocket.connect()
```