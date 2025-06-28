import Foundation
import Starscream

class SocketManager: NSObject, ObservableObject {
    static let shared = SocketManager()
    
    @Published var isConnected = false
    @Published var receivedMessages: [Message] = []
    
    private var webSocket: WebSocket?
    private let baseURL = "wss://chat.team-milestone.click/chat"
    private var subscribedRooms: Set<Int> = []
    
    override init() {
        super.init()
    }
    
    func connect(userId: Int) {
        WebSocketLogger.shared.log("Connecting to simple WebSocket: \(baseURL)", type: .info)
        
        guard let url = URL(string: baseURL) else {
            WebSocketLogger.shared.log("Invalid WebSocket URL", type: .error)
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
    }
    
    func subscribeToRoom(_ roomId: Int) {
        guard !subscribedRooms.contains(roomId) else { return }
        guard isConnected else {
            WebSocketLogger.shared.log("Not connected, cannot subscribe to room \(roomId)", type: .error)
            return
        }
        
        WebSocketLogger.shared.log("Subscribing to room: \(roomId)", type: .info)
        subscribedRooms.insert(roomId)
        
        // JSON 메시지로 룸 구독
        let subscribeMessage = [
            "type": "subscribe",
            "roomId": roomId
        ] as [String : Any]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: subscribeMessage),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            WebSocketLogger.shared.log("Sending subscribe message: \(jsonString)", type: .sent)
            webSocket?.write(string: jsonString)
        }
    }
    
    func sendMessage(roomId: Int, senderId: Int, content: String) {
        // 메시지 전송은 REST API를 사용 (WebSocket 사용 안함)
        WebSocketLogger.shared.log("메시지 전송은 REST API를 사용합니다", type: .info)
    }
    
    func markAsRead(roomId: Int, messageId: Int, userId: Int) {
        // 읽음 처리도 필요시 REST API 사용
        WebSocketLogger.shared.log("읽음 처리는 REST API를 사용합니다", type: .info)
    }
    
    func disconnect() {
        webSocket?.disconnect()
        isConnected = false
        subscribedRooms.removeAll()
    }
    
    private func handleWebSocketMessage(_ text: String) {
        WebSocketLogger.shared.log("Received message: \(text)", type: .received)
        
        // JSON 메시지 파싱
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            WebSocketLogger.shared.log("Failed to parse JSON: \(text)", type: .error)
            return
        }
        
        // 메시지 타입 확인
        if let type = json["type"] as? String {
            switch type {
            case "message":
                // 실시간 메시지 수신
                if let messageData = try? JSONSerialization.data(withJSONObject: json),
                   let message = try? JSONDecoder().decode(Message.self, from: messageData) {
                    DispatchQueue.main.async {
                        self.receivedMessages.append(message)
                        WebSocketLogger.shared.log("Added message to list: \(message.content)", type: .info)
                    }
                }
            default:
                WebSocketLogger.shared.log("Unknown message type: \(type)", type: .info)
            }
        }
    }
}

// MARK: - WebSocketDelegate
extension SocketManager: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: any WebSocketClient) {
        switch event {
        case .connected(let headers):
            WebSocketLogger.shared.log("WebSocket connected: \(headers)", type: .connected)
            DispatchQueue.main.async {
                self.isConnected = true
            }
            
        case .disconnected(let reason, let code):
            WebSocketLogger.shared.log("WebSocket disconnected: \(reason) code: \(code)", type: .disconnected)
            DispatchQueue.main.async {
                self.isConnected = false
            }
            
        case .text(let text):
            handleWebSocketMessage(text)
            
        case .binary(let data):
            if let text = String(data: data, encoding: .utf8) {
                handleWebSocketMessage(text)
            }
            
        case .error(let error):
            WebSocketLogger.shared.log("WebSocket error: \(error?.localizedDescription ?? "Unknown")", type: .error)
            
        default:
            break
        }
    }
}

