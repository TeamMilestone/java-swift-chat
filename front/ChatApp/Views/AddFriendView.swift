import SwiftUI

struct AddFriendView: View {
    @State private var searchText = ""
    @State private var searchResults: [Friend] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                // 디버그 정보
                VStack(alignment: .leading, spacing: 5) {
                    Text("현재 사용자: \(AuthService.shared.currentUser?.nickname ?? "없음") (ID: \(AuthService.shared.currentUser?.id ?? -1))")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("토큰: \(AuthService.shared.authToken != nil ? "있음" : "없음")")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("카카오톡 ID", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit {
                            searchUsers()
                        }
                        .onChange(of: searchText) { newValue in
                            if newValue.isEmpty {
                                searchResults = []
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchUsers()
                        }) {
                            Text("검색")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.yellow)
                                .cornerRadius(15)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .padding()
                
                if searchResults.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("친구 카카오톡 ID")
                            .font(.headline)
                        
                        Text("카카오톡 ID를 등록하고 검색을 허용한 친구만 찾을 수 있습니다.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 50)
                } else {
                    List(searchResults) { friend in
                        HStack {
                            AsyncImage(url: URL(string: "http://localhost:8080\(friend.profileImageUrl)")) { image in
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
                            
                            VStack(alignment: .leading) {
                                Text(friend.nickname)
                                    .font(.system(size: 16, weight: .medium))
                                Text("@\(friend.username)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                addFriend(friend)
                            }) {
                                Text("추가")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color.yellow)
                                    .cornerRadius(15)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
            .navigationTitle("친구 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
            }
        }
    }
    
    private func searchUsers() {
        guard !searchText.isEmpty,
              let userId = AuthService.shared.currentUser?.id else { 
            print("Search cancelled: searchText=\(searchText), userId=\(AuthService.shared.currentUser?.id ?? -1)")
            return 
        }
        
        print("Starting search: query=\(searchText), userId=\(userId)")
        print("Auth token: \(AuthService.shared.authToken ?? "nil")")
        
        Task {
            do {
                let results = try await ChatAPIService.shared.searchUsers(query: searchText, userId: userId)
                DispatchQueue.main.async {
                    self.searchResults = results
                    if results.isEmpty {
                        print("No results found for query: \(self.searchText)")
                    } else {
                        print("Found \(results.count) results")
                        for result in results {
                            print("  - \(result.username): \(result.nickname)")
                        }
                    }
                }
            } catch {
                print("Search error: \(error)")
                DispatchQueue.main.async {
                    self.alertMessage = "검색 중 오류가 발생했습니다: \(error.localizedDescription)"
                    self.showingAlert = true
                }
            }
        }
    }
    
    private func addFriend(_ friend: Friend) {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        Task {
            do {
                let success = try await ChatAPIService.shared.addFriend(userId: userId, friendId: friend.id)
                if success {
                    alertMessage = "\(friend.nickname)님을 친구로 추가했습니다."
                    showingAlert = true
                    
                    // 채팅방 생성
                    let chatRoomId = try await ChatAPIService.shared.createDirectChat(userId1: userId, userId2: friend.id)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } catch {
                alertMessage = "친구 추가 중 오류가 발생했습니다."
                showingAlert = true
            }
        }
    }
}