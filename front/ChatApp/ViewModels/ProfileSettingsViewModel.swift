import Foundation
import SwiftUI

class ProfileSettingsViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var profileImageData: Data?
    @Published var profileImageUrl: String?
    @Published var userId: String?
    @Published var isLoggedOut = false
    
    private let apiService = ChatAPIService.shared
    private let authService = AuthService.shared
    
    init() {
        loadUserProfile()
    }
    
    private func loadUserProfile() {
        if let user = authService.currentUser {
            userName = user.nickname
            profileImageUrl = user.profileImageUrl
            userId = String(user.id)
            print("Loaded user profile - nickname: \(userName), imageUrl: \(profileImageUrl ?? "nil"), userId: \(user.id)")
        } else {
            print("No current user found")
        }
    }
    
    func updateProfileImage(_ data: Data) {
        profileImageData = data
    }
    
    func saveProfile() {
        print("saveProfile called")
        guard let userId = authService.currentUser?.id else {
            print("No user ID found")
            return
        }
        
        guard let imageData = profileImageData else {
            print("No image data to upload")
            return
        }
        
        print("Uploading image for user \(userId), data size: \(imageData.count) bytes")
        
        Task {
            do {
                let newImageUrl = try await apiService.uploadProfileImage(userId: userId, imageData: imageData)
                print("Upload successful! New image URL: \(newImageUrl)")
                DispatchQueue.main.async {
                    self.profileImageUrl = newImageUrl
                    // 업로드 성공 후 현재 사용자 정보 업데이트
                    if var user = self.authService.currentUser {
                        user = User(id: user.id, username: user.username, nickname: user.nickname, profileImageUrl: newImageUrl)
                        self.authService.currentUser = user
                        // UserDefaults에도 저장
                        UserDefaults.standard.set(newImageUrl, forKey: "userProfileImageUrl")
                    }
                }
            } catch {
                print("Failed to upload profile image: \(error)")
                print("Error details: \(error.localizedDescription)")
            }
        }
    }
    
    func logout() {
        print("Logging out...")
        authService.logout()
        isLoggedOut = true
    }
}