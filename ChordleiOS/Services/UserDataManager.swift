import Foundation
import Combine

class UserDataManager: ObservableObject {
    @Published var username: String = ""
    @Published var isUsernameSet: Bool = false
    @Published var totalGamesPlayed: Int = 0
    @Published var bestScore: Int = 0
    @Published var bestStreak: Int = 0
    @Published var averageScore: Double = 0.0
    @Published var gameHistory: [GameSession] = []
    
    private let userDefaults = UserDefaults.standard
    private let apiService = APIService()
    
    init() {
        loadUserData()
    }
    
    func setUsername(_ name: String) {
        username = name.trimmingCharacters(in: .whitespacesAndNewlines)
        isUsernameSet = !username.isEmpty
        saveUserData()
        
        // Sync with backend
        Task {
            await syncUserWithBackend()
        }
    }
    
    func recordGameSession(score: Int, streak: Int, correctAnswers: Int, totalQuestions: Int) {
        let session = GameSession(
            username: username,
            score: score,
            streak: streak,
            correctAnswers: correctAnswers,
            totalQuestions: totalQuestions
        )
        
        gameHistory.append(session)
        totalGamesPlayed += 1
        bestScore = max(bestScore, score)
        bestStreak = max(bestStreak, streak)
        
        // Calculate average score
        let totalScore = gameHistory.reduce(0) { $0 + $1.score }
        averageScore = Double(totalScore) / Double(gameHistory.count)
        
        saveUserData()
        
        // Sync with backend
        Task {
            await submitGameSession(session)
        }
    }
    
    private func loadUserData() {
        username = userDefaults.string(forKey: "username") ?? ""
        isUsernameSet = !username.isEmpty
        totalGamesPlayed = userDefaults.integer(forKey: "totalGamesPlayed")
        bestScore = userDefaults.integer(forKey: "bestScore")
        bestStreak = userDefaults.integer(forKey: "bestStreak")
        averageScore = userDefaults.double(forKey: "averageScore")
        
        // Load game history
        if let data = userDefaults.data(forKey: "gameHistory"),
           let history = try? JSONDecoder().decode([GameSession].self, from: data) {
            gameHistory = history
        }
    }
    
    private func saveUserData() {
        userDefaults.set(username, forKey: "username")
        userDefaults.set(totalGamesPlayed, forKey: "totalGamesPlayed")
        userDefaults.set(bestScore, forKey: "bestScore")
        userDefaults.set(bestStreak, forKey: "bestStreak")
        userDefaults.set(averageScore, forKey: "averageScore")
        
        // Save game history
        if let data = try? JSONEncoder().encode(gameHistory) {
            userDefaults.set(data, forKey: "gameHistory")
        }
    }
    
    @MainActor
    private func syncUserWithBackend() async {
        do {
            let _ = try await apiService.registerUser(username: username)
        } catch {
            print("Failed to sync user with backend: \(error)")
        }
    }
    
    @MainActor
    private func submitGameSession(_ session: GameSession) async {
        do {
            let _ = try await apiService.submitGameSession(session)
        } catch {
            print("Failed to submit game session: \(error)")
        }
    }
}
