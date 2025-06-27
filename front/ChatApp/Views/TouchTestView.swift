import SwiftUI

struct TouchTestView: View {
    @State private var touchLog: [String] = []
    
    var body: some View {
        VStack {
            Text("터치 테스트")
                .font(.largeTitle)
                .padding()
            
            // 테스트 1: 간단한 Button
            Button(action: {
                addLog("Button 클릭됨")
            }) {
                Text("일반 Button")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            // 테스트 2: onTapGesture
            Text("onTapGesture 테스트")
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .onTapGesture {
                    addLog("onTapGesture 실행됨")
                }
                .padding()
            
            // 테스트 3: FriendRow와 유사한 구조
            HStack {
                Text("친구 이름")
                    .padding()
                Spacer()
                Text("...")
                    .padding()
                    .background(Circle().stroke(Color.gray))
                    .onTapGesture {
                        addLog("... 버튼 클릭됨")
                    }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .onTapGesture {
                addLog("전체 행 클릭됨")
            }
            .padding()
            
            // 로그 표시
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(touchLog, id: \.self) { log in
                        Text(log)
                            .font(.caption)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 200)
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(8)
            
            Button("로그 초기화") {
                touchLog.removeAll()
            }
            .padding()
        }
    }
    
    private func addLog(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        touchLog.append("[\(timestamp)] \(message)")
        print("TouchTest: \(message)")
    }
}