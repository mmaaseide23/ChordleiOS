import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Circle()
                        .fill(ColorTheme.primaryGreen.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text(String(userDataManager.username.prefix(1)).uppercased())
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(ColorTheme.primaryGreen)
                        )
                    
                    Text(userDataManager.username)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    Text("Chord Master in Training")
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.textSecondary)
                }
                .padding(.top, 20)
                
                VStack(spacing: 16) {
                    Text("Your Statistics")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ProfileStatCard(title: "Games Played", value: "\(gameManager.totalGames)", icon: "gamecontroller")
                        ProfileStatCard(title: "Current Score", value: "\(gameManager.score)", icon: "star.fill")
                        ProfileStatCard(title: "Best Streak", value: "\(gameManager.streak)", icon: "flame.fill")
                        ProfileStatCard(title: "Accuracy", value: "85%", icon: "target")
                    }
                }
                .themedCard()
                
                VStack(spacing: 16) {
                    Text("Achievements")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        AchievementBadge(title: "First Steps", icon: "music.note", isUnlocked: gameManager.totalGames > 0)
                        AchievementBadge(title: "Streak Master", icon: "flame", isUnlocked: gameManager.streak >= 5)
                        AchievementBadge(title: "Perfect Pitch", icon: "ear", isUnlocked: false)
                        AchievementBadge(title: "Speed Demon", icon: "bolt", isUnlocked: false)
                        AchievementBadge(title: "Chord Wizard", icon: "wand.and.stars", isUnlocked: false)
                        AchievementBadge(title: "Guitar Hero", icon: "guitars", isUnlocked: false)
                    }
                }
                .themedCard()
                
                VStack(spacing: 16) {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    VStack(spacing: 12) {
                        SettingsRow(title: "Change Username", icon: "person.circle") {
                            userDataManager.isUsernameSet = false
                            presentationMode.wrappedValue.dismiss()
                        }
                        
                        SettingsRow(title: "Reset Statistics", icon: "arrow.clockwise") {
                            // Reset stats functionality
                        }
                        
                        SettingsRow(title: "About Chordle", icon: "info.circle") {
                            // About page functionality
                        }
                    }
                }
                .themedCard()
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .themedBackground()
    }
}

struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(ColorTheme.primaryGreen)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorTheme.secondaryBackground)
        )
    }
}

struct AchievementBadge: View {
    let title: String
    let icon: String
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isUnlocked ? ColorTheme.primaryGreen : ColorTheme.textSecondary.opacity(0.5))
            
            Text(title)
                .font(.caption2)
                .foregroundColor(isUnlocked ? ColorTheme.textPrimary : ColorTheme.textSecondary.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isUnlocked ? ColorTheme.primaryGreen.opacity(0.1) : ColorTheme.secondaryBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isUnlocked ? ColorTheme.primaryGreen.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(ColorTheme.primaryGreen)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(ColorTheme.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(ColorTheme.textSecondary)
                    .font(.caption)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(ColorTheme.secondaryBackground)
            )
        }
    }
}

#Preview {
    NavigationView {
        ProfileView()
            .environmentObject(UserDataManager())
            .environmentObject(GameManager())
    }
}
