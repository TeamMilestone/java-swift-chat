import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var chatRoom: ChatRoom
    
    let currentUserId: Int
    private let socketManager = SocketManager.shared
    private let apiService = ChatAPIService.shared
    private var cancellables = Set<AnyCancellable>()
    private var messageTimer: Timer?
    
    init(chatRoom: ChatRoom, currentUserId: Int) {
        self.chatRoom = chatRoom
        self.currentUserId = currentUserId
        
        // WebSocket 연결 시작
        if !socketManager.isConnected {
            socketManager.connect(userId: currentUserId)
        }
        
        setupSocket()
        loadMessages()
        startPolling()
    }
    
    deinit {
        messageTimer?.invalidate()
        messageTimer = nil
    }
    
    private func setupSocket() {
        // WebSocket 연결 상태를 확인하고 구독
        if socketManager.isConnected {
            socketManager.subscribeToRoom(chatRoom.id)
        } else {
            // 연결이 완료되면 구독
            socketManager.$isConnected
                .filter { $0 }
                .first()
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    self.socketManager.subscribeToRoom(self.chatRoom.id)
                }
                .store(in: &cancellables)
        }
        
        socketManager.$receivedMessages
            .sink { [weak self] newMessages in
                self?.messages.append(contentsOf: newMessages.filter { $0.chatRoomId == self?.chatRoom.id })
            }
            .store(in: &cancellables)
    }
    
    private func startPolling() {
        // 1초마다 메시지를 다시 로드
        messageTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.loadMessages()
            }
        }
    }
    
    private func stopPolling() {
        messageTimer?.invalidate()
        messageTimer = nil
    }
    
    private func loadMessages() {
        Task {
            do {
                let newMessages = try await apiService.fetchMessages(roomId: chatRoom.id)
                await MainActor.run {
                    // 첫 로드인 경우 전체 메시지를 시간순으로 설정
                    if self.messages.isEmpty {
                        self.messages = newMessages.sorted { $0.timestamp < $1.timestamp }
                    } else {
                        // 기존 메시지와 중복 제거하면서 새 메시지만 추가
                        let existingIds = Set(self.messages.map { $0.id })
                        let uniqueNewMessages = newMessages.filter { !existingIds.contains($0.id) }
                        
                        if !uniqueNewMessages.isEmpty {
                            self.messages.append(contentsOf: uniqueNewMessages)
                            // 전체 메시지를 시간순으로 정렬 (오래된 것부터 최신 순)
                            self.messages.sort { $0.timestamp < $1.timestamp }
                        }
                    }
                }
            } catch {
                print("Failed to load messages: \(error)")
            }
        }
    }
    
    func sendMessage(_ content: String) {
        print("ChatViewModel sendMessage called with content: \(content)")
        
        // REST API로 메시지 전송
        Task {
            do {
                let sentMessage = try await apiService.sendMessage(roomId: chatRoom.id, senderId: currentUserId, content: content)
                print("Message sent successfully via REST API: \(sentMessage)")
                
                // 메시지 목록 다시 로드
                loadMessages()
            } catch {
                print("Failed to send message: \(error)")
                
                // 에러 발생시에도 로컬에 임시로 추가
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let tempMessage = Message(
                    id: Int.random(in: 100000...999999),
                    content: content,
                    senderId: currentUserId,
                    senderName: AuthService.shared.currentUser?.nickname ?? "Me",
                    senderProfileImageUrl: AuthService.shared.currentUser?.profileImageUrl ?? "/api/files/default.png",
                    chatRoomId: chatRoom.id,
                    sentAt: formatter.string(from: Date()),
                    unreadCount: 0
                )
                
                await MainActor.run {
                    self.messages.append(tempMessage)
                }
            }
        }
    }
    
    func updateAnnouncement(_ announcement: String) {
        Task {
            do {
                try await apiService.updateAnnouncement(roomId: chatRoom.id, announcement: announcement)
                await MainActor.run {
                    self.chatRoom = ChatRoom(
                        id: self.chatRoom.id,
                        name: self.chatRoom.name,
                        isGroup: self.chatRoom.isGroup,
                        announcement: announcement,
                        updatedAt: self.chatRoom.updatedAt,
                        participants: self.chatRoom.participants,
                        lastMessage: self.chatRoom.lastMessage,
                        unreadCount: self.chatRoom.unreadCount
                    )
                }
            } catch {
                print("Failed to update announcement: \(error)")
            }
        }
    }
}