import SwiftUI

struct ProfileSettingsView: View {
    @StateObject private var viewModel = ProfileSettingsViewModel()
    @State private var showingImagePicker = false
    @State private var selectedUIImage: UIImage?
    @State private var profileImage: Image?
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    if let profileImage = profileImage {
                        profileImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    } else if let profileImageUrl = viewModel.profileImageUrl {
                        let fullUrl = "https://chat.team-milestone.click\(profileImageUrl)"
                        let _ = print("Profile image URL: \(fullUrl)")
                        AsyncImage(url: URL(string: fullUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure(let error):
                                let _ = print("Image loading failed: \(error)")
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Text("프로필 사진 변경")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                    
                    Text(viewModel.userName)
                        .font(.system(size: 20, weight: .medium))
                    
                    // 디버깅 정보
                    VStack(alignment: .leading, spacing: 4) {
                        Text("디버깅 정보:")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.red)
                        
                        Text("프로필 이미지 URL: \(viewModel.profileImageUrl ?? "없음")")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        
                        if let profileImageUrl = viewModel.profileImageUrl {
                            Text("전체 URL: https://chat.team-milestone.click\(profileImageUrl)")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        
                        Text("사용자 ID: \(viewModel.userId ?? "없음")")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        
                        if viewModel.profileImageData != nil {
                            Text("새 이미지 선택됨 (저장 버튼을 눌러주세요)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.top, 10)
                }
                .padding(.top, 40)
                
                Spacer()
                
                Button(action: {
                    viewModel.logout()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("로그아웃")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        viewModel.saveProfile()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedUIImage)
            }
            .onChange(of: selectedUIImage) { newImage in
                if let image = newImage {
                    profileImage = Image(uiImage: image)
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        viewModel.updateProfileImage(imageData)
                    }
                }
            }
        }
    }
}