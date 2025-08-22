import SwiftUI

struct StatsView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Statistics")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.textPrimary)
            
            HStack(spacing: 20) {
                StatCard(title: "Games Played", value: "\(gameManager.totalGames)")
                StatCard(title: "Current Score", value: "\(gameManager.score)")
                StatCard(title: "Best Streak", value: "\(gameManager.streak)")
            }
            
            if gameManager.gameState == .playing {
                VStack(spacing: 8) {
                    Text("Round \(gameManager.currentRound) of 10")
                        .font(.headline)
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    ProgressView(value: Double(gameManager.currentRound - 1), total: 10)
                        .progressViewStyle(LinearProgressViewStyle(tint: ColorTheme.primaryGreen))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
                .padding(.top)
            }
        }
        .padding()
        .themedCard()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.primaryGreen)
            
            Text(title)
                .font(.caption)
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorTheme.secondaryBackground)
        )
    }
}

#Preview {
    StatsView()
        .environmentObject(GameManager())
        .themedBackground()
}
