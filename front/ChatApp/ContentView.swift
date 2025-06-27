import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @EnvironmentObject var authService: AuthService
    @State private var showDebugView = false
    
    var body: some View {
        Group {
            if authService.authToken != nil {
                ChatListView()
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            authService.checkAuthStatus()
            isLoggedIn = authService.authToken != nil
        }
        .onChange(of: authService.authToken) { newToken in
            isLoggedIn = newToken != nil
        }
    }
}