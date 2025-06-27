import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()
    @State private var showingProfile = false
    @State private var showingAddFriend = false
    @State private var showingFriendList = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.chatRooms) { chatRoom in
                    NavigationLink(destination: ChatView(chatRoom: chatRoom, currentUserId: viewModel.currentUserId)) {
                        ChatRoomRow(chatRoom: chatRoom, currentUserId: viewModel.currentUserId)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("채팅")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // WebSocket 디버그 버튼
                        Button(action: {
                            print("=== WebSocket Debug Info ===")
                            print("Connected: \(SocketManager.shared.isConnected)")
                            print("Received Messages: \(SocketManager.shared.receivedMessages.count)")
                            print("===========================")
                            
                            // 간단한 테스트
                            if !SocketManager.shared.isConnected {
                                let userId = AuthService.shared.currentUser?.id ?? 1
                                SocketManager.shared.connect(userId: userId)
                                print("Attempting to connect WebSocket...")
                            }
                        }) {
                            Image(systemName: "ant.circle.fill")
                                .foregroundColor(SocketManager.shared.isConnected ? .green : .red)
                        }
                        
                        Button(action: {
                            showingFriendList = true
                        }) {
                            Image(systemName: "person.2")
                        }
                        
                        Button(action: {
                            showingAddFriend = true
                        }) {
                            Image(systemName: "person.badge.plus")
                        }
                        
                        Button(action: {
                            showingProfile = true
                        }) {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileSettingsView()
            }
            .sheet(isPresented: $showingAddFriend) {
                AddFriendView()
                    .onDisappear {
                        viewModel.refresh()
                    }
            }
            .sheet(isPresented: $showingFriendList) {
                FriendListView()
            }
            .onAppear {
                viewModel.refresh()
                
                // WebSocket 연결 시작
                if !SocketManager.shared.isConnected {
                    let userId = AuthService.shared.currentUser?.id ?? 1
                    SocketManager.shared.connect(userId: userId)
                }
            }
        }
    }
}

struct ChatRoomRow: View {
    let chatRoom: ChatRoom
    let currentUserId: Int
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: "http://localhost:8080\(chatRoom.getProfileImageUrl(currentUserId: currentUserId))")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
            }
            .frame(width: 56, height: 56)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chatRoom.getDisplayName(currentUserId: currentUserId))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text(formatTime(chatRoom.lastMessageTime))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text(chatRoom.lastMessage?.content ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if let unreadCount = chatRoom.unreadCount, unreadCount > 0 {
                        Text("\(unreadCount)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "a h:mm"
        } else if calendar.isDateInYesterday(date) {
            return "어제"
        } else {
            formatter.dateFormat = "M월 d일"
        }
        
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}