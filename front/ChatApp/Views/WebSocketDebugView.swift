import SwiftUI
import Combine

struct WebSocketDebugView: View {
    @ObservedObject var socketManager = SocketManager.shared
    @State private var logs: [DebugLog] = []
    @State private var testRoomId: String = "1"
    @State private var testMessage: String = "Test message"
    @State private var isMonitoring = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Connection Status
                HStack {
                    Circle()
                        .fill(socketManager.isConnected ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    Text(socketManager.isConnected ? "Connected" : "Disconnected")
                        .font(.caption)
                    Spacer()
                    Button(isMonitoring ? "Stop" : "Start") {
                        if isMonitoring {
                            stopMonitoring()
                        } else {
                            startMonitoring()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Test Controls
                VStack(alignment: .leading, spacing: 8) {
                    Text("Test Controls")
                        .font(.headline)
                    
                    HStack {
                        TextField("Room ID", text: $testRoomId)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        
                        Button("Subscribe") {
                            socketManager.subscribeToRoom(Int(testRoomId) ?? 1)
                            addLog("Subscribing to room \(testRoomId)", type: .info)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        TextField("Test message", text: $testMessage)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Send") {
                            let roomId = Int(testRoomId) ?? 1
                            let userId = AuthService.shared.currentUser?.id ?? 1
                            socketManager.sendMessage(roomId: roomId, senderId: userId, content: testMessage)
                            addLog("Sending: \(testMessage)", type: .sent)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        Button("Connect") {
                            let userId = AuthService.shared.currentUser?.id ?? 1
                            socketManager.connect(userId: userId)
                            addLog("Connecting with userId: \(userId)", type: .info)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Disconnect") {
                            socketManager.disconnect()
                            addLog("Disconnecting", type: .info)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Clear Logs") {
                            logs.removeAll()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                }
                .padding()
                
                // Message Counter
                HStack {
                    Text("Received Messages: \(socketManager.receivedMessages.count)")
                        .font(.caption)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Logs
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach(logs) { log in
                                HStack(alignment: .top) {
                                    Text(log.timestamp, style: .time)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .frame(width: 60)
                                    
                                    Image(systemName: log.icon)
                                        .foregroundColor(log.color)
                                        .frame(width: 20)
                                    
                                    Text(log.message)
                                        .font(.caption)
                                        .foregroundColor(log.color)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .id(log.id)
                            }
                        }
                    }
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8)
                    .onChange(of: logs.count) { _ in
                        withAnimation {
                            proxy.scrollTo(logs.last?.id, anchor: .bottom)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("WebSocket Debug")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                startMonitoring()
            }
            .onDisappear {
                stopMonitoring()
            }
        }
    }
    
    private func startMonitoring() {
        isMonitoring = true
        
        // Monitor received messages
        socketManager.$receivedMessages
            .sink { messages in
                if let lastMessage = messages.last {
                    self.addLog("Received: \(lastMessage.content) from \(lastMessage.senderName)", type: .received)
                }
            }
            .store(in: &cancellables)
        
        // Monitor connection status
        socketManager.$isConnected
            .sink { connected in
                self.addLog("Connection: \(connected ? "Connected" : "Disconnected")", type: connected ? .connected : .disconnected)
            }
            .store(in: &cancellables)
        
        // Redirect console logs
        WebSocketLogger.shared.onLog = { message, type in
            self.addLog(message, type: type)
        }
    }
    
    private func stopMonitoring() {
        isMonitoring = false
        cancellables.removeAll()
        WebSocketLogger.shared.onLog = nil
    }
    
    private func addLog(_ message: String, type: LogType) {
        let log = DebugLog(message: message, type: type)
        DispatchQueue.main.async {
            self.logs.append(log)
            // Keep only last 100 logs
            if self.logs.count > 100 {
                self.logs.removeFirst()
            }
        }
    }
    
    @State private var cancellables = Set<AnyCancellable>()
}

struct DebugLog: Identifiable {
    let id = UUID()
    let timestamp = Date()
    let message: String
    let type: LogType
    
    var icon: String {
        switch type {
        case .sent: return "arrow.up.circle.fill"
        case .received: return "arrow.down.circle.fill"
        case .connected: return "wifi"
        case .disconnected: return "wifi.slash"
        case .error: return "exclamationmark.triangle.fill"
        case .info: return "info.circle"
        }
    }
    
    var color: Color {
        switch type {
        case .sent: return .blue
        case .received: return .green
        case .connected: return .green
        case .disconnected: return .red
        case .error: return .red
        case .info: return .gray
        }
    }
}