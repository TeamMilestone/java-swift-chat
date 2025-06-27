import Foundation
import Combine

@MainActor
class ChatListViewModel: ObservableObject {
    @Published var chatRooms: [ChatRoom] = []
    private let apiService = ChatAPIService.shared
    private let authService = AuthService.shared
    
    var currentUserId: Int {
        authService.currentUser?.id ?? 0
    }
    
    init() {
        loadChatRooms()
    }
    
    func loadChatRooms() {
        guard currentUserId > 0 else { return }
        
        Task {
            do {
                let rooms = try await apiService.fetchChatRooms(userId: currentUserId)
                await MainActor.run {
                    self.chatRooms = rooms
                }
            } catch {
                print("Failed to load chat rooms: \(error)")
            }
        }
    }
    
    func refresh() {
        loadChatRooms()
    }
}