import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // 인증 상태 확인
        AuthService.shared.checkAuthStatus()
        
        // Socket 연결 초기화
        if let userId = AuthService.shared.currentUser?.id {
            SocketManager.shared.connect(userId: userId)
        }
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        SocketManager.shared.disconnect()
    }
}