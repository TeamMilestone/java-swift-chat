import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let username: String
    let nickname: String
    let profileImageUrl: String
    let lastSeen: String
    
    init(id: Int, username: String, nickname: String, profileImageUrl: String = "/api/files/default.png", lastSeen: String = "") {
        self.id = id
        self.username = username
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.lastSeen = lastSeen
    }
    
    // 커스텀 디코딩 추가
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        nickname = try container.decode(String.self, forKey: .nickname)
        
        // profileImageUrl 디코딩 시 디버깅
        if let profileImageUrlValue = try? container.decode(String.self, forKey: .profileImageUrl) {
            profileImageUrl = profileImageUrlValue
            print("Decoded profileImageUrl: \(profileImageUrlValue)")
        } else {
            profileImageUrl = "/api/files/default.png"
            print("Failed to decode profileImageUrl, using default")
        }
        
        // lastSeen은 옵셔널로 처리
        lastSeen = (try? container.decode(String.self, forKey: .lastSeen)) ?? ""
    }
}

struct AuthResponse: Codable {
    let user: User
    let token: String
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct RegisterRequest: Codable {
    let username: String
    let password: String
    let nickname: String
}