import Foundation

class ChatAPIService: ObservableObject {
    static let shared = ChatAPIService()
    
    private let baseURL = "http://localhost:8080/api"
    
    private func createAuthRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let token = AuthService.shared.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if method != "GET" {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
    
    func fetchChatRooms(userId: Int) async throws -> [ChatRoom] {
        let url = URL(string: "\(baseURL)/chat/rooms?userId=\(userId)")!
        let request = createAuthRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 디버깅을 위한 API 응답 로깅
        if let jsonString = String(data: data, encoding: .utf8) {
            print("ChatRooms API Response: \(jsonString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let chatRooms = try JSONDecoder().decode([ChatRoom].self, from: data)
        return chatRooms
    }
    
    func fetchMessages(roomId: Int, page: Int = 0, size: Int = 50) async throws -> [Message] {
        let url = URL(string: "\(baseURL)/chat/rooms/\(roomId)/messages?page=\(page)&size=\(size)")!
        let request = createAuthRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let messages = try JSONDecoder().decode([Message].self, from: data)
        return messages
    }
    
    func createDirectChat(userId1: Int, userId2: Int) async throws -> Int {
        let url = URL(string: "\(baseURL)/chat/rooms/direct")!
        var request = createAuthRequest(url: url, method: "POST")
        
        let requestBody = CreateDirectChatRequest(userId1: userId1, userId2: userId2)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let chatRoomResponse = try JSONDecoder().decode(ChatRoomResponse.self, from: data)
        return chatRoomResponse.chatRoomId
    }
    
    func updateAnnouncement(roomId: Int, announcement: String) async throws {
        let url = URL(string: "\(baseURL)/chat/rooms/\(roomId)/announcement")!
        var request = createAuthRequest(url: url, method: "PUT")
        
        let requestBody = ["announcement": announcement]
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    func uploadProfileImage(userId: Int, imageData: Data) async throws -> String {
        let url = URL(string: "\(baseURL)/users/\(userId)/profile-image")!
        print("Uploading profile image to: \(url)")
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = AuthService.shared.authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Using auth token: Bearer \(token.prefix(10))...")
        }
        
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        print("Request body size: \(body.count) bytes")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Upload response status: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Upload response: \(responseString)")
            }
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let result = try JSONDecoder().decode([String: String].self, from: data)
        return result["profileImageUrl"] ?? ""
    }
    
    func loadImage(from urlString: String) async throws -> Data {
        let fullURL = URL(string: "\(baseURL)\(urlString)")!
        let (data, _) = try await URLSession.shared.data(from: fullURL)
        return data
    }
    
    func searchUsers(query: String, userId: Int) async throws -> [Friend] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw URLError(.badURL)
        }
        let url = URL(string: "\(baseURL)/friends/search?query=\(encodedQuery)&userId=\(userId)")!
        let request = createAuthRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("Search URL: \(url)")
        print("Response status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
        print("Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let friends = try JSONDecoder().decode([Friend].self, from: data)
        return friends
    }
    
    func getFriends(userId: Int) async throws -> [Friend] {
        let url = URL(string: "\(baseURL)/friends?userId=\(userId)")!
        let request = createAuthRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let friends = try JSONDecoder().decode([Friend].self, from: data)
        return friends
    }
    
    func addFriend(userId: Int, friendId: Int) async throws -> Bool {
        let url = URL(string: "\(baseURL)/friends/add")!
        var request = createAuthRequest(url: url, method: "POST")
        
        let requestBody = AddFriendRequest(userId: userId, friendId: friendId)
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let friendResponse = try JSONDecoder().decode(FriendResponse.self, from: data)
        return friendResponse.success
    }
    
    func removeFriend(userId: Int, friendId: Int) async throws -> Bool {
        let url = URL(string: "\(baseURL)/friends/remove?userId=\(userId)&friendId=\(friendId)")!
        let request = createAuthRequest(url: url, method: "DELETE")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let friendResponse = try JSONDecoder().decode(FriendResponse.self, from: data)
        return friendResponse.success
    }
    
    func sendMessage(roomId: Int, senderId: Int, content: String) async throws -> Message {
        let url = URL(string: "\(baseURL)/chat/rooms/\(roomId)/messages")!
        var request = createAuthRequest(url: url, method: "POST")
        
        let messageRequest = ["senderId": senderId, "content": content] as [String : Any]
        request.httpBody = try JSONSerialization.data(withJSONObject: messageRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let messageResponse = try JSONDecoder().decode(Message.self, from: data)
        return messageResponse
    }
}