import Foundation
import Combine

class WebSocketService: NSObject, ObservableObject {
    @Published var isConnected = false
    @Published var receivedMessages: [Message] = []
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession!
    private let baseURL = "ws://localhost:8080/ws"
    
    override init() {
        super.init()
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }
    
    func connect(userId: String) {
        guard let url = URL(string: "\(baseURL)?userId=\(userId)") else { return }
        
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        isConnected = false
    }
    
    func sendMessage(_ message: Message) {
        guard let data = try? JSONEncoder().encode(message) else { return }
        let message = URLSessionWebSocketTask.Message.data(data)
        
        webSocketTask?.send(message) { error in
            if let error = error {
                print("Error sending message: \(error)")
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    if let decodedMessage = try? JSONDecoder().decode(Message.self, from: data) {
                        DispatchQueue.main.async {
                            self?.receivedMessages.append(decodedMessage)
                        }
                    }
                case .string(let text):
                    print("Received string: \(text)")
                @unknown default:
                    fatalError()
                }
                
                self?.receiveMessage()
                
            case .failure(let error):
                print("Error receiving message: \(error)")
            }
        }
    }
}

extension WebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.isConnected = true
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        DispatchQueue.main.async { [weak self] in
            self?.isConnected = false
        }
    }
}