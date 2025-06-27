import Foundation

struct Message: Identifiable, Codable, Equatable {
    let id: Int
    let content: String
    let senderId: Int
    let senderName: String
    let senderProfileImageUrl: String
    let chatRoomId: Int
    let sentAt: String
    let unreadCount: Int
    
    var timestamp: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        // 밀리초 부분이 있을 수도 없을 수도 있으므로 두 가지 형식 시도
        if let date = formatter.date(from: sentAt) {
            return date
        }
        
        // 밀리초 없는 형식도 시도
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.date(from: sentAt) ?? Date()
    }
}

struct SendMessageRequest: Codable {
    let senderId: Int
    let content: String
}

struct ReadMessageRequest: Codable {
    let messageId: Int
    let userId: Int
}