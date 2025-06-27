import Foundation
import Starscream

class SockJSClient: NSObject {
    private var webSocket: WebSocket?
    private var baseURL: String
    private var sessionId: String?
    private var serverNumber: String = "000"
    private var transportId: String = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    
    var onMessage: ((String) -> Void)?
    var onConnected: (() -> Void)?
    var onDisconnected: (() -> Void)?
    
    init(baseURL: String) {
        self.baseURL = baseURL
        super.init()
    }
    
    func connect() {
        // SockJS 프로토콜: 먼저 info 엔드포인트 호출
        fetchInfo { [weak self] in
            self?.createSession()
        }
    }
    
    private func fetchInfo(completion: @escaping () -> Void) {
        guard let url = URL(string: "\(baseURL)/info") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                print("SockJS info response: \(String(data: data, encoding: .utf8) ?? "")")
            }
            completion()
        }.resume()
    }
    
    private func createSession() {
        // SockJS 세션 ID 생성
        sessionId = String(format: "%03d", Int.random(in: 0...999))
        
        // WebSocket URL 생성: /ws/{server}/{session}/{transport}
        let wsURL = "\(baseURL)/\(serverNumber)/\(sessionId)/websocket"
        
        guard let url = URL(string: wsURL) else {
            print("Invalid SockJS WebSocket URL: \(wsURL)")
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
        
        print("SockJS connecting to: \(wsURL)")
    }
    
    func send(_ message: String) {
        // SockJS 메시지 포맷: ["message"]
        let sockJSMessage = "[\"\(message.replacingOccurrences(of: "\"", with: "\\\""))\"]"
        webSocket?.write(string: sockJSMessage)
    }
    
    func disconnect() {
        webSocket?.disconnect()
    }
}

extension SockJSClient: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: any WebSocketClient) {
        switch event {
        case .connected:
            print("SockJS WebSocket connected")
            
        case .disconnected(let reason, let code):
            print("SockJS WebSocket disconnected: \(reason) code: \(code)")
            onDisconnected?()
            
        case .text(let text):
            print("SockJS received: \(text)")
            handleSockJSFrame(text)
            
        case .error(let error):
            print("SockJS WebSocket error: \(error?.localizedDescription ?? "Unknown")")
            
        default:
            break
        }
    }
    
    private func handleSockJSFrame(_ frame: String) {
        // SockJS 프레임 타입
        let firstChar = frame.first
        
        switch firstChar {
        case "o":
            // Open frame
            print("SockJS connection opened")
            onConnected?()
            
        case "a":
            // Array frame (messages)
            let messageData = String(frame.dropFirst())
            if let data = messageData.data(using: .utf8),
               let messages = try? JSONSerialization.jsonObject(with: data) as? [String] {
                for message in messages {
                    onMessage?(message)
                }
            }
            
        case "h":
            // Heartbeat
            print("SockJS heartbeat")
            
        case "c":
            // Close frame
            print("SockJS close frame: \(frame)")
            onDisconnected?()
            
        default:
            print("Unknown SockJS frame: \(frame)")
        }
    }
}