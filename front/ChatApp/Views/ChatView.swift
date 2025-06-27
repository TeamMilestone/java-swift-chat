import SwiftUI

// MARK: - ChatView
struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @State private var messageText = ""
    @State private var showingSettings = false

    // ─────────────── Init ───────────────
    init(chatRoom: ChatRoom, currentUserId: Int) {
        _viewModel = StateObject(
            wrappedValue: ChatViewModel(chatRoom: chatRoom,
                                        currentUserId: currentUserId)
        )
    }

    // ─────────────── Body ───────────────
    var body: some View {
        VStack(spacing: 0) {
            // 상단 공지사항
            if let notice = viewModel.chatRoom.announcement {
                NoticeBar(notice: notice)
            }
            
            // 메시지 리스트
            messageListView
            
            // 메시지 입력창
            MessageInputView(text: $messageText) {
                let txt = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !txt.isEmpty else { return }
                viewModel.sendMessage(txt)
                messageText = ""
            }
        }
        .background(Color(UIColor.systemGray6)) // 전체 배경색 지정
        .ignoresSafeArea(edges: .top) // 네비게이션 바 배경이 항상 보이도록 함
        .navigationTitle(viewModel.chatRoom.getDisplayName(currentUserId: viewModel.currentUserId))
        .navigationBarTitleDisplayMode(.inline)
        // [수정] 최신 SwiftUI 스타일 가이드에 맞춰 toolbar 수정
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.chatRoom.getDisplayName(currentUserId: viewModel.currentUserId)).fontWeight(.semibold)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape")
                }
                .foregroundStyle(.primary)
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color(UIColor.systemBackground), for: .navigationBar)
        .sheet(isPresented: $showingSettings) {
            ProfileSettingsView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    // ─────────────── Message List View ───────────────
    private var messageListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    // [핵심 수정] viewModel.messages를 뒤집어서 ForEach에 전달
                    // 이렇게 해야 최신 메시지가 배열의 첫번째 요소가 되어, 화면 맨 아래에 표시됨
                    ForEach(viewModel.messages.reversed()) { message in
                        MessageBubble(
                            message: message,
                            isCurrentUser: message.senderId == viewModel.currentUserId
                        )
                        .id(message.id)
                        // 각 셀을 다시 뒤집어 정상으로 보이게 함
                        .scaleEffect(x: 1, y: -1)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            // ScrollView 컨텐츠 전체를 뒤집음
            .scaleEffect(x: 1, y: -1)
            .onAppear {
                // 뷰가 처음 나타날 때, 원본 배열의 마지막(last) 항목, 즉 최신 메시지로 스크롤
                if let lastMessage = viewModel.messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
            .onChange(of: viewModel.messages) { _, newMessages in
                // 새 메시지가 추가될 때도 동일하게 맨 아래로 스크롤
                if let latestMessage = newMessages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(latestMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}


// MARK: - 하위 뷰 (Subviews)
struct NoticeBar: View {
    let notice: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "megaphone.fill")
                .font(.system(size: 14))
            Text(notice)
                .font(.system(size: 14))
            Spacer()
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemGray5))
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // 내가 보낸 메시지가 아닐 경우, 타임스탬프 왼쪽에 표시
            if !isCurrentUser {
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            // 메시지 버블
            Text(message.content)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isCurrentUser ? Color.yellow : Color.white)
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // 내가 보낸 메시지일 경우, 타임스탬프 오른쪽에 표시
            if isCurrentUser {
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        // HStack 전체를 왼쪽 또는 오른쪽으로 정렬
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
    }
    
    private func formatTime(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}

struct MessageInputView: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    let onSend: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 8) {
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium))
                }
                
                HStack {
                    TextField("메시지를 입력하세요", text: $text, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(1...5)
                        .focused($isFocused)
                        .onSubmit(onSend)
                        .submitLabel(.send)
                    
                    if !text.isEmpty {
                        Button(action: onSend) {
                            Image(systemName: "paperplane.fill")
                                .fontWeight(.medium)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemGray5))
                .clipShape(Capsule())
                .animation(.spring(response: 0.3), value: text.isEmpty)
            }
            .foregroundStyle(.secondary)
            .padding()
            .background(Color(UIColor.systemBackground))
        }
    }
}



#Preview {
    NavigationStack {
        ChatView(
            chatRoom: ChatRoom(
                id: 1,
                name: "Gemini",
                isGroup: false,
                announcement: "중요: 내일 오후 2시 전체 미팅",
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                participants: [],
                lastMessage: nil,
                unreadCount: 0
            ),
            currentUserId: 1
        )
    }
}