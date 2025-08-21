import Foundation

class APIService {
    private let baseURL = "http://localhost:8000"  // Change this to your backend URL
    private let session = URLSession.shared
    
    func registerUser(username: String) async throws -> UserResponse {
        let url = URL(string: "\(baseURL)/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["username": username]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(UserResponse.self, from: data)
    }
    
    func submitGameSession(_ gameSession: GameSession) async throws -> GameSessionResponse {
        let url = URL(string: "\(baseURL)/games/session")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": gameSession.username,
            "score": gameSession.score,
            "streak": gameSession.streak,
            "correct_answers": gameSession.correctAnswers,
            "total_questions": gameSession.totalQuestions
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(GameSessionResponse.self, from: data)
    }
    
    func getUserStats(username: String) async throws -> UserStatsResponse {
        let url = URL(string: "\(baseURL)/users/\(username)/stats")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(UserStatsResponse.self, from: data)
    }
}

// MARK: - API Models
struct UserResponse: Codable {
    let id: Int
    let username: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, username
        case createdAt = "created_at"
    }
}

struct GameSessionResponse: Codable {
    let id: Int
    let username: String
    let score: Int
    let streak: Int
    let correctAnswers: Int
    let totalQuestions: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, username, score, streak
        case correctAnswers = "correct_answers"
        case totalQuestions = "total_questions"
        case createdAt = "created_at"
    }
}

struct UserStatsResponse: Codable {
    let totalGames: Int
    let bestScore: Int
    let bestStreak: Int
    let averageScore: Double
    let totalCorrect: Int
    let totalQuestions: Int
    
    enum CodingKeys: String, CodingKey {
        case totalGames = "total_games"
        case bestScore = "best_score"
        case bestStreak = "best_streak"
        case averageScore = "average_score"
        case totalCorrect = "total_correct"
        case totalQuestions = "total_questions"
    }
}

enum APIError: Error {
    case invalidResponse
    case networkError
    case decodingError
}
