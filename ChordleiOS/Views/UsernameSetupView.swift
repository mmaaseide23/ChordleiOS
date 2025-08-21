import SwiftUI

struct UsernameSetupView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var inputUsername = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // App Logo/Title
            VStack(spacing: 12) {
                Text("🎵")
                    .font(.system(size: 60))
                
                Text("Chordle")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Test your chord recognition skills")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Username Input
            VStack(spacing: 16) {
                Text("Choose a username to track your progress")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                TextField("Enter username", text: $inputUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                Button(action: setUsername) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        }
                        Text(isLoading ? "Setting up..." : "Start Playing")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(inputUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                  Color.gray : Color.blue)
                    )
                }
                .disabled(inputUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            
            Spacer()
            
            Text("Your progress will be saved locally and synced to our servers")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
    
    private func setUsername() {
        let trimmedUsername = inputUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else { return }
        
        isLoading = true
        
        // Add a small delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            userDataManager.setUsername(trimmedUsername)
            isLoading = false
        }
    }
}

#Preview {
    UsernameSetupView()
        .environmentObject(UserDataManager())
}
