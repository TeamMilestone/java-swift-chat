import Foundation

struct ChatRoom: Identifiable, Codable {
    let id: Int
    let name: String?
    let isGroup: Bool
    let announcement: String?
    let updatedAt: String?
    let participants: [User]
    let lastMessage: LastMessage?
    let unreadCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isGroup = "group"
        case announcement
        case updatedAt
        case participants
        case lastMessage
        case unreadCount
    }
    
    var lastMessageTime: Date {
        if let lastMessage = lastMessage {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return formatter.date(from: lastMessage.sentAt) ?? Date()
        }
        return Date()
    }
    
    var displayName: String {
        if isGroup {
            return name ?? "그룹 채팅"
        } else {
            return participants.first?.nickname ?? "Unknown"
        }
    }
    
    func getDisplayName(currentUserId: Int) -> String {
        if isGroup {
            return name ?? "그룹 채팅"
        } else {
            // 1:1 채팅에서는 현재 사용자가 아닌 상대방의 이름을 반환
            let otherParticipant = participants.first { $0.id != currentUserId }
            return otherParticipant?.nickname ?? participants.first?.nickname ?? "Unknown"
        }
    }
    
    func getProfileImageUrl(currentUserId: Int) -> String {
        if !isGroup {
            // 1:1 채팅에서는 현재 사용자가 아닌 상대방의 프로필 이미지 URL을 반환
            let otherParticipant = participants.first { $0.id != currentUserId }
            return otherParticipant?.profileImageUrl ?? participants.first?.profileImageUrl ?? "/api/files/default.png"
        }
        // 그룹 채팅에서는 기본 이미지
        return "/api/files/default.png"
    }
    
    // 기존 코드와의 호환성을 위해 남겨둠
    var profileImageUrl: String {
        if !isGroup, let participant = participants.first {
            return participant.profileImageUrl
        }
        return "/api/files/default.png"
    }
}

struct LastMessage: Codable {
    let id: Int
    let content: String
    let senderId: Int
    let senderName: String
    let senderProfileImageUrl: String
    let chatRoomId: Int
    let sentAt: String
    let unreadCount: Int
}

struct CreateDirectChatRequest: Codable {
    let userId1: Int
    let userId2: Int
}

struct CreateGroupChatRequest: Codable {
    let name: String
    let participantIds: [Int]
}

struct ChatRoomResponse: Codable {
    let chatRoomId: Int
}