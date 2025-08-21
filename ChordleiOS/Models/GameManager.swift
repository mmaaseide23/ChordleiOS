import Foundation
import Combine

class GameManager: ObservableObject {
    @Published var currentRound = 1
    @Published var score = 0
    @Published var isGameActive = false
    @Published var currentChord: ChordType?
    @Published var selectedChord: ChordType?
    @Published var gameState: GameState = .waiting
    @Published var streak = 0
    @Published var totalGames = 0
    @Published var currentAttempt = 1
    @Published var maxAttempts = 6
    @Published var attempts: [ChordType?] = []
    
    @Published var selectedAudioOption: AudioOption = .chord
    @Published var jumbledFingerPositions: [Int] = []
    @Published var revealedFingerIndex: Int = -1
    
    private var audioManager: AudioManager?
    
    private let maxRounds = 10
    
    enum GameState {
        case waiting
        case playing
        case answered
        case gameOver
    }
    
    enum HintType {
        case chordNoFingers     // Attempts 1-2: Full chord, no finger display
        case chordSlow          // Attempt 3: Slower chord
        case individualStrings  // Attempt 4: Each string separately
        case audioOptions       // Attempt 5: User chooses audio + jumbled fingers
        case singleFingerReveal // Attempt 6: One correct finger shown
    }
    
    enum AudioOption: String, CaseIterable {
        case chord = "Full Chord"
        case arpeggiated = "Arpeggiated"
        case individual = "Individual Strings"
        case bass = "Bass Notes Only"
        case treble = "Treble Notes Only"
    }
    
    var currentHintType: HintType {
        switch currentAttempt {
        case 1, 2:
            return .chordNoFingers
        case 3:
            return .chordSlow
        case 4:
            return .individualStrings
        case 5:
            return .audioOptions
        case 6:
            return .singleFingerReveal
        default:
            return .chordNoFingers
        }
    }
    
    var hintDescription: String {
        switch currentHintType {
        case .chordNoFingers:
            return "Listen to the full chord"
        case .chordSlow:
            return "Chord played arpeggiated (fast strum)"
        case .individualStrings:
            return "Each string played separately"
        case .audioOptions:
            return "Choose what to hear + see jumbled finger positions"
        case .singleFingerReveal:
            return "One finger position revealed"
        }
    }
    
    func setAudioManager(_ audioManager: AudioManager) {
        self.audioManager = audioManager
    }
    
    func startNewGame() {
        currentRound = 1
        score = 0
        streak = 0
        isGameActive = true
        gameState = .waiting
        startNewRound()
    }
    
    func startNewRound() {
        guard currentRound <= maxRounds else {
            endGame()
            return
        }
        
        currentChord = ChordType.allCases.randomElement()
        selectedChord = nil
        currentAttempt = 1
        attempts = Array(repeating: nil, count: maxAttempts)
        gameState = .playing
        
        selectedAudioOption = .chord
        jumbledFingerPositions = []
        revealedFingerIndex = -1
        
        audioManager?.resetForNewAttempt()
    }
    
    func submitGuess(_ guess: ChordType) {
        guard gameState == .playing, currentAttempt <= maxAttempts else { return }
        
        selectedChord = guess
        attempts[currentAttempt - 1] = guess
        
        if guess == currentChord {
            let points = max(60 - (currentAttempt - 1) * 10, 10)
            score += points
            streak += 1
            gameState = .answered
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.nextRound()
            }
        } else {
            currentAttempt += 1
            
            audioManager?.resetForNewAttempt()
            
            if currentAttempt == 5 {
                generateJumbledFingerPositions()
            } else if currentAttempt == 6 {
                revealRandomFingerPosition()
            }
            
            if currentAttempt > maxAttempts {
                streak = 0
                gameState = .answered
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.nextRound()
                }
            }
        }
    }
    
    func nextRound() {
        currentRound += 1
        startNewRound()
    }
    
    private func endGame() {
        gameState = .gameOver
        isGameActive = false
        totalGames += 1
    }
    
    func generateJumbledFingerPositions() {
        guard let chord = currentChord else { return }
        let correctPositions = chord.fingerPositions.map { $0.fret }
        jumbledFingerPositions = correctPositions.shuffled()
    }
    
    func revealRandomFingerPosition() {
        guard let chord = currentChord else { return }
        let fingerPositions = chord.fingerPositions
        if !fingerPositions.isEmpty {
            revealedFingerIndex = Int.random(in: 0..<fingerPositions.count)
        }
    }
}
