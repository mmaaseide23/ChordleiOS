import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var audioManager: AudioManager
    @State private var guitarNeckRef: GuitarNeckView?
    
    var body: some View {
        VStack(spacing: 20) {
            GuitarNeckView(
                chord: gameManager.currentChord,
                currentAttempt: gameManager.currentAttempt,
                jumbledPositions: gameManager.jumbledFingerPositions,
                revealedFingerIndex: gameManager.revealedFingerIndex
            )
            .onAppear {
                gameManager.setAudioManager(audioManager)
            }
            .onChange(of: audioManager.isPlaying) { oldValue, newValue in
                if newValue && !oldValue {
                    NotificationCenter.default.post(name: .triggerStringShake, object: nil)
                }
            }
            
            if gameManager.currentAttempt == 6 && gameManager.revealedFingerIndex >= 0 {
                FingerRevealHint()
                    .transition(.slide.combined(with: .opacity))
            }
            
            // Audio Controls - now more compact without circular progress
            AudioControlView()
            
            // Game Status
            if gameManager.gameState == .playing {
                Text("Listen and guess the chord!")
                    .font(.headline)
                    .foregroundColor(ColorTheme.textSecondary)
            } else if gameManager.gameState == .answered {
                ResultView()
            } else if gameManager.gameState == .gameOver {
                GameOverView()
            }
            
            // Chord Selection Grid
            if gameManager.gameState == .playing || gameManager.gameState == .answered {
                ChordSelectionView()
            }
        }
        .padding()
        .animation(.easeInOut(duration: 0.5), value: audioManager.isPlaying)
        .onChange(of: gameManager.currentAttempt) { oldValue, newValue in
            audioManager.resetForNewAttempt()
        }
    }
}

struct FingerRevealHint: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "hand.point.up.fill")
                    .foregroundColor(Color.yellow)
                    .font(.title3)
                
                Text("One finger position revealed!")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ColorTheme.textPrimary)
            }
            
            Text("The highlighted yellow dot shows where one finger should be placed")
                .font(.caption)
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.yellow.opacity(0.1),
                            Color.yellow.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.4), lineWidth: 1)
                )
        )
        .shadow(color: Color.yellow.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

struct ResultView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 12) {
            let isCorrect = gameManager.selectedChord == gameManager.currentChord
            
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(isCorrect ? ColorTheme.primaryGreen : ColorTheme.error)
            
            Text(isCorrect ? "Correct!" : "Wrong!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isCorrect ? ColorTheme.primaryGreen : ColorTheme.error)
            
            if !isCorrect {
                Text("The correct answer was \(gameManager.currentChord?.displayName ?? "")")
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.textSecondary)
            }
            
            if gameManager.streak > 1 {
                Text("Streak: \(gameManager.streak)")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(ColorTheme.accentGreen.opacity(0.2))
                    .foregroundColor(ColorTheme.lightGreen)
                    .cornerRadius(12)
            }
        }
        .padding()
        .themedCard()
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct GameOverView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.textPrimary)
            
            VStack(spacing: 8) {
                Text("Final Score: \(gameManager.score)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(ColorTheme.textPrimary)
                
                Text("Best Streak: \(gameManager.streak)")
                    .font(.headline)
                    .foregroundColor(ColorTheme.textSecondary)
            }
            
            Button(action: { gameManager.startNewGame() }) {
                Text("Play Again")
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(ColorTheme.primaryGreen)
                    )
            }
        }
        .padding()
        .themedCard()
        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    GameView()
        .environmentObject(GameManager())
        .environmentObject(AudioManager())
        .themedBackground()
}
