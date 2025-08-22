import SwiftUI

struct ChordSelectionView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showParticles = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            if !gameManager.attempts.isEmpty {
                VStack(spacing: 12) {
                    Text("Previous Attempts:")
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    HStack(spacing: 12) {
                        ForEach(0..<gameManager.maxAttempts, id: \.self) { index in
                            ZStack {
                                Circle()
                                    .fill(attemptColor(for: index))
                                    .frame(width: 16, height: 16)
                                    .overlay(
                                        Circle()
                                            .stroke(ColorTheme.primaryGreen.opacity(0.3), lineWidth: index == gameManager.currentAttempt - 1 ? 2 : 0)
                                            .scaleEffect(index == gameManager.currentAttempt - 1 ? 1.3 : 1.0)
                                    )
                                    .animation(.easeInOut(duration: 0.3), value: gameManager.currentAttempt)
                                
                                if gameManager.attempts.count > index, let attempt = gameManager.attempts[index] {
                                    Text(attempt.displayName)
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(ColorTheme.textPrimary)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
            }
            
            VStack(spacing: 8) {
                Text("Select the chord:")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.textPrimary)
                
                Rectangle()
                    .fill(ColorTheme.primaryGreen)
                    .frame(width: 60, height: 2)
                    .cornerRadius(1)
            }
            
            ZStack {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(ChordType.allCases) { chord in
                        ChordButton(chord: chord)
                    }
                }
                
                if showParticles {
                    Circle()
                        .fill(ColorTheme.primaryGreen.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .scaleEffect(showParticles ? 2.0 : 0.1)
                        .opacity(showParticles ? 0.0 : 1.0)
                        .animation(.easeOut(duration: 1.0), value: showParticles)
                        .allowsHitTesting(false)
                }
            }
        }
        .padding()
        .themedCard()
        .onChange(of: gameManager.gameState) { oldValue, newValue in
            if newValue == .answered && gameManager.selectedChord == gameManager.currentChord {
                showParticles = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showParticles = false
                }
            }
        }
    }
    
    private func attemptColor(for index: Int) -> Color {
        if index < gameManager.attempts.count {
            if let attempt = gameManager.attempts[index] {
                return attempt == gameManager.currentChord ? ColorTheme.primaryGreen : ColorTheme.error
            }
        } else if index == gameManager.currentAttempt - 1 {
            return ColorTheme.accentGreen
        }
        return ColorTheme.textTertiary.opacity(0.3)
    }
}

struct ChordButton: View {
    let chord: ChordType
    @EnvironmentObject var gameManager: GameManager
    @State private var bounceAnimation = false
    @State private var glowAnimation = false
    
    private var buttonColor: Color {
        if gameManager.gameState == .answered {
            if chord == gameManager.currentChord {
                return ColorTheme.primaryGreen
            } else if chord == gameManager.selectedChord && chord != gameManager.currentChord {
                return ColorTheme.error
            }
        } else if chord == gameManager.selectedChord {
            return ColorTheme.accentGreen
        }
        return ColorTheme.secondaryBackground
    }
    
    private var textColor: Color {
        if gameManager.gameState == .answered {
            if chord == gameManager.currentChord ||
               (chord == gameManager.selectedChord && chord != gameManager.currentChord) {
                return ColorTheme.textPrimary
            }
        } else if chord == gameManager.selectedChord {
            return ColorTheme.textPrimary
        }
        return ColorTheme.textPrimary
    }
    
    var body: some View {
        Button(action: { selectChord() }) {
            Text(chord.displayName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(textColor)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [buttonColor, buttonColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    gameManager.gameState == .answered && chord == gameManager.currentChord ?
                                    ColorTheme.lightGreen : ColorTheme.textTertiary.opacity(0.2),
                                    lineWidth: gameManager.gameState == .answered && chord == gameManager.currentChord ? 2 : 1
                                )
                        )
                        .shadow(
                            color: gameManager.gameState == .answered && chord == gameManager.currentChord ?
                            ColorTheme.primaryGreen.opacity(0.4) : Color.clear,
                            radius: glowAnimation ? 8 : 4
                        )
                )
        }
        .disabled(gameManager.gameState != .playing)
        .scaleEffect(bounceAnimation ? 1.1 : (gameManager.selectedChord == chord ? 0.95 : 1.0))
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: bounceAnimation)
        .animation(.easeInOut(duration: 0.1), value: gameManager.selectedChord)
        .onChange(of: gameManager.gameState) { oldValue, newValue in
            if newValue == .answered && chord == gameManager.currentChord {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowAnimation = true
                }
            } else {
                glowAnimation = false
            }
        }
    }
    
    private func selectChord() {
        guard gameManager.gameState == .playing else { return }
        
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            bounceAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            bounceAnimation = false
        }
        
        gameManager.submitGuess(chord)
    }
}

#Preview {
    ChordSelectionView()
        .environmentObject(GameManager())
        .themedBackground()
}
