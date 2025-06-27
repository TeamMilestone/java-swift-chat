import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var showingRegister = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "message.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                
                Text("채팅 앱")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    TextField("사용자명", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("비밀번호", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal, 40)
                .padding(.top, 30)
                
                Button(action: login) {
                    Text("로그인")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .disabled(username.isEmpty || password.isEmpty)
                
                Button(action: { showingRegister = true }) {
                    Text("계정이 없으신가요? 회원가입")
                        .foregroundColor(.blue)
                }
                
                VStack(spacing: 10) {
                    Text("테스트 계정")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("a@a / 111222")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("b@b / 111222")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingRegister) {
                RegisterView(isPresented: $showingRegister, isLoggedIn: $isLoggedIn)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
            }
        }
    }
    
    private func login() {
        Task {
            do {
                let success = try await AuthService.shared.login(username: username, password: password)
                if success {
                    isLoggedIn = true
                }
            } catch {
                alertMessage = "로그인에 실패했습니다: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
}