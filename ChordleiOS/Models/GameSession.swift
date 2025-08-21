import Foundation

struct GameSession: Codable {
    let id: UUID
    let username: String
    let score: Int
    let streak: Int
    let correctAnswers: Int
    let totalQuestions: Int
    let createdAt: Date
    
    init(username: String, score: Int, streak: Int, correctAnswers: Int, totalQuestions: Int) {
        self.id = UUID()
        self.username = username
        self.score = score
        self.streak = streak
        self.correctAnswers = correctAnswers
        self.totalQuestions = totalQuestions
        self.createdAt = Date()
    }
}
