import SwiftUI

struct FriendListView: View {
    @State private var friends: [Friend] = []
    @State private var showingAddFriend = false
    @State private var showingRemoveAlert = false
    @State private var friendToRemove: Friend?
    @State private var showingChat = false
    @State private var selectedChatRoom: ChatRoom?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                if friends.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("친구가 없습니다")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showingAddFriend = true
                        }) {
                            Text("친구 추가하기")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.yellow)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 100)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(friends) { friend in
                                FriendRow(friend: friend, onRemove: {
                                    print("Remove button tapped for: \(friend.nickname)")
                                    friendToRemove = friend
                                    showingRemoveAlert = true
                                }, onChatTap: {
                                    print("Friend row tapped for: \(friend.nickname)")
                                    openChat(with: friend)
                                })
                                Divider()
                                    .padding(.leading, 70)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("친구")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddFriend = true
                    }) {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFriend) {
                AddFriendView()
                    .onDisappear {
                        loadFriends()
                    }
            }
            .alert(isPresented: $showingRemoveAlert) {
                Alert(
                    title: Text("친구 끊기"),
                    message: Text("\(friendToRemove?.nickname ?? "")님과 친구를 끊으시겠습니까?"),
                    primaryButton: .destructive(Text("끊기")) {
                        if let friend = friendToRemove {
                            removeFriend(friend)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                loadFriends()
            }
            .background(
                NavigationLink(
                    destination: selectedChatRoom.map { chatRoom in
                        ChatView(chatRoom: chatRoom, currentUserId: AuthService.shared.currentUser?.id ?? 0)
                    },
                    isActive: $showingChat
                ) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }
    
    private func loadFriends() {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        Task {
            do {
                let fetchedFriends = try await ChatAPIService.shared.getFriends(userId: userId)
                DispatchQueue.main.async {
                    self.friends = fetchedFriends
                }
            } catch {
                print("Failed to load friends: \(error)")
            }
        }
    }
    
    private func removeFriend(_ friend: Friend) {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        Task {
            do {
                let success = try await ChatAPIService.shared.removeFriend(userId: userId, friendId: friend.id)
                if success {
                    DispatchQueue.main.async {
                        self.friends.removeAll { $0.id == friend.id }
                    }
                }
            } catch {
                print("Failed to remove friend: \(error)")
            }
        }
    }
    
    private func openChat(with friend: Friend) {
        print("openChat called for friend: \(friend.nickname)")
        guard let userId = AuthService.shared.currentUser?.id else { 
            print("No current user ID")
            return 
        }
        
        Task {
            do {
                print("Fetching chat rooms for user: \(userId)")
                // 먼저 기존 채팅방이 있는지 확인
                let chatRooms = try await ChatAPIService.shared.fetchChatRooms(userId: userId)
                print("Fetched \(chatRooms.count) chat rooms")
                
                // 1:1 채팅방 찾기
                if let existingRoom = chatRooms.first(where: { chatRoom in
                    !chatRoom.isGroup && chatRoom.participants.contains(where: { $0.id == friend.id })
                }) {
                    print("Found existing chat room: \(existingRoom.id)")
                    DispatchQueue.main.async {
                        self.selectedChatRoom = existingRoom
                        self.showingChat = true
                        print("Navigation state - selectedChatRoom: \(self.selectedChatRoom != nil), showingChat: \(self.showingChat)")
                    }
                } else {
                    print("No existing room, creating new chat")
                    // 채팅방이 없으면 새로 생성
                    let chatRoomId = try await ChatAPIService.shared.createDirectChat(userId1: userId, userId2: friend.id)
                    print("Created new chat room: \(chatRoomId)")
                    
                    // 생성된 채팅방 정보 가져오기
                    let updatedChatRooms = try await ChatAPIService.shared.fetchChatRooms(userId: userId)
                    if let newRoom = updatedChatRooms.first(where: { $0.id == chatRoomId }) {
                        print("Found new room in updated list: \(newRoom)")
                        DispatchQueue.main.async {
                            self.selectedChatRoom = newRoom
                            self.showingChat = true
                            print("Navigation state - selectedChatRoom: \(self.selectedChatRoom != nil), showingChat: \(self.showingChat)")
                        }
                    } else {
                        print("Could not find new room in updated list")
                    }
                }
            } catch {
                print("Failed to open chat: \(error)")
            }
        }
    }
}

struct FriendRow: View {
    let friend: Friend
    let onRemove: () -> Void
    let onChatTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: "https://chat.team-milestone.click\(friend.profileImageUrl)")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(friend.nickname)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                Text("@\(friend.username)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // ellipsis 버튼
            Image(systemName: "ellipsis")
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .background(Circle().fill(Color.white))
                )
                .onTapGesture {
                    print("Ellipsis tapped for \(friend.nickname)")
                    onRemove()
                }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color.white)
        .contentShape(Rectangle()) // 전체 영역을 터치 가능하게 만듦
        .onTapGesture {
            print("Row tapped for \(friend.nickname)")
            onChatTap()
        }
        .overlay(
            // ellipsis 버튼 영역만 별도로 처리
            HStack {
                Spacer()
                Color.clear
                    .frame(width: 50, height: 50)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print("Ellipsis overlay tapped for \(friend.nickname)")
                        onRemove()
                    }
            }
            .padding(.horizontal)
        )
    }
}