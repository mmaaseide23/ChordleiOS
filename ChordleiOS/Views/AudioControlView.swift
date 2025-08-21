import SwiftUI

struct AudioControlView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var gameManager: GameManager
    @State private var pulseAnimation = false
    @State private var glowAnimation = false
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Attempt \(gameManager.currentAttempt) of \(gameManager.maxAttempts)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(ColorTheme.primaryGreen)
                
                Text(gameManager.hintDescription)
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.bottom, 8)
            
            if gameManager.currentAttempt == 5 {
                AudioOptionsSelector()
                    .environmentObject(gameManager)
                    .transition(.slide.combined(with: .opacity))
            }
            
            Button(action: playCurrentChord) {
                HStack(spacing: 12) {
                    ZStack {
                        if audioManager.isPlaying {
                            Circle()
                                .fill(ColorTheme.lightGreen.opacity(0.3))
                                .frame(width: 40, height: 40)
                                .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                                .opacity(pulseAnimation ? 0 : 1)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false), value: pulseAnimation)
                        }
                        
                        Image(systemName: audioManager.isPlaying ? "speaker.wave.2.fill" :
                              audioManager.isLoading ? "hourglass" : "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(ColorTheme.textPrimary)
                            .rotationEffect(.degrees(audioManager.isLoading ? 360 : 0))
                            .animation(audioManager.isLoading ? .linear(duration: 1.0).repeatForever(autoreverses: false) : .default, value: audioManager.isLoading)
                    }
                    
                    Text(audioManager.isLoading ? "Loading..." :
                         audioManager.isPlaying ? "Playing..." :
                         audioManager.hasPlayedThisAttempt ? "Already Played" :
                         gameManager.currentAttempt == 5 ? "Play \(gameManager.selectedAudioOption.rawValue)" : "Play Chord")
                        .fontWeight(.semibold)
                        .foregroundColor(ColorTheme.textPrimary)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                colors: audioManager.isLoading || audioManager.hasPlayedThisAttempt ?
                                    [ColorTheme.textTertiary, ColorTheme.textTertiary.opacity(0.8)] :
                                    [ColorTheme.primaryGreen, ColorTheme.lightGreen],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: ColorTheme.primaryGreen.opacity(glowAnimation && !audioManager.hasPlayedThisAttempt ? 0.6 : 0.3), radius: glowAnimation && !audioManager.hasPlayedThisAttempt ? 12 : 6)
                        .scaleEffect(audioManager.isPlaying ? 1.05 : 1.0)
                )
            }
            .disabled(audioManager.isLoading || gameManager.gameState != .playing || audioManager.hasPlayedThisAttempt)
            .animation(.easeInOut(duration: 0.2), value: audioManager.isPlaying)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    glowAnimation = true
                }
            }
            
            if let error = audioManager.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(ColorTheme.error)
                        .font(.caption)
                    
                    Text(error)
                        .foregroundColor(ColorTheme.error)
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ColorTheme.error.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(ColorTheme.error.opacity(0.3), lineWidth: 1)
                        )
                )
                .transition(.slide.combined(with: .opacity))
            }
        }
        .onChange(of: audioManager.isPlaying) { oldValue, newValue in
            if newValue {
                pulseAnimation = true
            } else {
                pulseAnimation = false
            }
        }
    }
    
    private func playCurrentChord() {
        guard let chord = gameManager.currentChord else { return }
        audioManager.playChord(chord, hintType: gameManager.currentHintType, audioOption: gameManager.selectedAudioOption)
    }
}

struct AudioOptionsSelector: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Choose what to hear:")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ColorTheme.textSecondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(GameManager.AudioOption.allCases, id: \.self) { option in
                    AudioOptionButton(
                        option: option,
                        isSelected: gameManager.selectedAudioOption == option
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            gameManager.selectedAudioOption = option
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ColorTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ColorTheme.primaryGreen.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct AudioOptionButton: View {
    let option: GameManager.AudioOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: iconForOption(option))
                    .font(.caption)
                    .foregroundColor(isSelected ? ColorTheme.textPrimary : ColorTheme.textSecondary)
                
                Text(option.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? ColorTheme.textPrimary : ColorTheme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [ColorTheme.primaryGreen, ColorTheme.lightGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [ColorTheme.surfaceSecondary, ColorTheme.surfaceSecondary.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? ColorTheme.lightGreen : ColorTheme.textTertiary.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
    
    private func iconForOption(_ option: GameManager.AudioOption) -> String {
        switch option {
        case .chord:
            return "music.note.list"
        case .arpeggiated:
            return "waveform"
        case .individual:
            return "dot.radiowaves.left.and.right"
        case .bass:
            return "speaker.wave.1"
        case .treble:
            return "speaker.wave.3"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AudioControlView()
            .environmentObject({
                let gm = GameManager()
                gm.currentAttempt = 5
                return gm
            }())
            .environmentObject(AudioManager())
        
        AudioControlView()
            .environmentObject({
                let gm = GameManager()
                gm.currentAttempt = 3
                return gm
            }())
            .environmentObject(AudioManager())
    }
    .themedBackground()
}
