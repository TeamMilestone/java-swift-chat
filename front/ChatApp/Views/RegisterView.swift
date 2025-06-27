import SwiftUI

struct RegisterView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var nickname = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @StateObject private var authService = AuthService()
    @Binding var isPresented: Bool
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                
                Text("회원가입")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    TextField("사용자명 (3-20자)", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("닉네임", text: $nickname)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("비밀번호 (최소 6자)", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal, 40)
                .padding(.top, 30)
                
                Button(action: register) {
                    Text("가입하기")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .disabled(username.count < 3 || password.count < 6 || nickname.isEmpty)
                
                Spacer()
            }
            .navigationBarItems(leading: Button("취소") {
                isPresented = false
            })
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
            }
        }
    }
    
    private func register() {
        Task {
            do {
                let success = try await authService.register(username: username, password: password, nickname: nickname)
                if success {
                    isLoggedIn = true
                    isPresented = false
                }
            } catch {
                alertMessage = "회원가입에 실패했습니다: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
}