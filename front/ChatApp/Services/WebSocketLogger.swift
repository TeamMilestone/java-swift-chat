import Foundation

// WebSocket Logger Singleton
class WebSocketLogger {
    static let shared = WebSocketLogger()
    var onLog: ((String, LogType) -> Void)?
    
    func log(_ message: String, type: LogType = .info) {
        print("[WebSocket] \(message)")
        onLog?(message, type)
    }
}

enum LogType {
    case sent, received, connected, disconnected, error, info
}