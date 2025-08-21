import SwiftUI

struct ContentView: View {
    @StateObject private var gameManager = GameManager()
    @StateObject private var audioManager = AudioManager()
    @StateObject private var userDataManager = UserDataManager()
    
    var body: some View {
        NavigationView {
            if !userDataManager.isUsernameSet {
                UsernameSetupView()
                    .environmentObject(userDataManager)
            } else {
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 20) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Chordle")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(ColorTheme.primaryGreen)
                                    
                                    Text("Welcome, \(userDataManager.username)!")
                                        .font(.subheadline)
                                        .foregroundColor(ColorTheme.textSecondary)
                                }
                                
                                Spacer()
                                
                                NavigationLink(destination: ProfileView().environmentObject(userDataManager).environmentObject(gameManager)) {
                                    Image(systemName: "person.circle")
                                        .font(.title2)
                                        .foregroundColor(ColorTheme.primaryGreen)
                                }
                            }
                            .padding(.top, 10) // Added top padding for better spacing
                            
                            // Main Game Area - removed stats, they're now in profile
                            GameView()
                                .environmentObject(gameManager)
                                .environmentObject(audioManager)
                            
                            Spacer(minLength: 20)
                        }
                        .padding(.horizontal)
                        .padding(.top, geometry.safeAreaInsets.top > 0 ? 0 : 20) // Conditional top padding
                    }
                }
                .navigationBarHidden(true)
                .environmentObject(userDataManager)
                .themedBackground()
                .ignoresSafeArea(.container, edges: .top) // Proper safe area handling
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            gameManager.startNewGame()
        }
        .onChange(of: gameManager.gameState) { oldValue, newValue in
            if newValue == .gameOver {
                userDataManager.recordGameSession(
                    score: gameManager.score,
                    streak: gameManager.streak,
                    correctAnswers: gameManager.score / 10,
                    totalQuestions: 10
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
