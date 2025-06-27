import SwiftUI

@main
struct ChatAppApp: App {
    @StateObject private var authService = AuthService.shared
    
    init() {
        print("ChatApp Started")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .onAppear {
                    print("ContentView appeared")
                    authService.checkAuthStatus()
                }
        }
    }
}