import Foundation

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: User?
    @Published var authToken: String?
    
    private let baseURL = "https://chat.team-milestone.click/api"
    
    func login(username: String, password: String) async throws -> Bool {
        let url = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequest = LoginRequest(username: username, password: password)
        request.httpBody = try JSONEncoder().encode(loginRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        // 디버깅: 서버로부터 받은 데이터 확인
        print("=== Login Response Debugging ===")
        print("Raw JSON data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
        print("Decoded user.id: \(authResponse.user.id)")
        print("Decoded user.username: \(authResponse.user.username)")
        print("Decoded user.nickname: \(authResponse.user.nickname)")
        print("Decoded user.profileImageUrl: \(authResponse.user.profileImageUrl)")
        print("Decoded token: \(authResponse.token)")
        print("================================")
        
        DispatchQueue.main.async {
            self.currentUser = authResponse.user
            self.authToken = authResponse.token
            
            UserDefaults.standard.set(authResponse.token, forKey: "authToken")
            UserDefaults.standard.set(authResponse.user.id, forKey: "userId")
            UserDefaults.standard.set(authResponse.user.nickname, forKey: "userNickname")
            UserDefaults.standard.set(authResponse.user.profileImageUrl, forKey: "userProfileImageUrl")
            
            // UserDefaults에 저장된 값 확인
            print("=== UserDefaults after login ===")
            print("Saved profileImageUrl: \(UserDefaults.standard.string(forKey: "userProfileImageUrl") ?? "nil")")
            print("================================")
        }
        
        return true
    }
    
    func register(username: String, password: String, nickname: String) async throws -> Bool {
        let url = URL(string: "\(baseURL)/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let registerRequest = RegisterRequest(username: username, password: password, nickname: nickname)
        request.httpBody = try JSONEncoder().encode(registerRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        // 디버깅: 서버로부터 받은 데이터 확인
        print("=== Register Response Debugging ===")
        print("Raw JSON data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
        print("Decoded user.id: \(authResponse.user.id)")
        print("Decoded user.username: \(authResponse.user.username)")
        print("Decoded user.nickname: \(authResponse.user.nickname)")
        print("Decoded user.profileImageUrl: \(authResponse.user.profileImageUrl)")
        print("Decoded token: \(authResponse.token)")
        print("===================================")
        
        DispatchQueue.main.async {
            self.currentUser = authResponse.user
            self.authToken = authResponse.token
            
            UserDefaults.standard.set(authResponse.token, forKey: "authToken")
            UserDefaults.standard.set(authResponse.user.id, forKey: "userId")
            UserDefaults.standard.set(authResponse.user.nickname, forKey: "userNickname")
            UserDefaults.standard.set(authResponse.user.profileImageUrl, forKey: "userProfileImageUrl")
            
            // UserDefaults에 저장된 값 확인
            print("=== UserDefaults after register ===")
            print("Saved profileImageUrl: \(UserDefaults.standard.string(forKey: "userProfileImageUrl") ?? "nil")")
            print("===================================")
        }
        
        return true
    }
    
    func logout() {
        currentUser = nil
        authToken = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userNickname")
        UserDefaults.standard.removeObject(forKey: "userProfileImageUrl")
    }
    
    func checkAuthStatus() {
        print("=== CheckAuthStatus Debugging ===")
        print("authToken: \(UserDefaults.standard.string(forKey: "authToken") ?? "nil")")
        print("userId: \(UserDefaults.standard.object(forKey: "userId") ?? "nil")")
        print("userNickname: \(UserDefaults.standard.string(forKey: "userNickname") ?? "nil")")
        print("userProfileImageUrl: \(UserDefaults.standard.string(forKey: "userProfileImageUrl") ?? "nil")")
        
        if let token = UserDefaults.standard.string(forKey: "authToken"),
           let userId = UserDefaults.standard.object(forKey: "userId") as? Int,
           let nickname = UserDefaults.standard.string(forKey: "userNickname") {
            self.authToken = token
            let profileImageUrl = UserDefaults.standard.string(forKey: "userProfileImageUrl") ?? "/api/files/default.png"
            print("Using profileImageUrl: \(profileImageUrl)")
            self.currentUser = User(id: userId, username: "", nickname: nickname, profileImageUrl: profileImageUrl)
            print("Created currentUser with profileImageUrl: \(self.currentUser?.profileImageUrl ?? "nil")")
        }
        print("=================================")
    }
}