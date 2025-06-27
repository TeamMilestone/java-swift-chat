import Foundation

struct Friend: Identifiable, Codable {
    let id: Int
    let username: String
    let nickname: String
    let profileImageUrl: String
    let lastSeen: String
}

struct AddFriendRequest: Codable {
    let userId: Int
    let friendId: Int
}

struct FriendResponse: Codable {
    let success: Bool
    let message: String
}