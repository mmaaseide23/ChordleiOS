import SwiftUI

struct ColorTheme {
    static let background = Color(red: 0.04, green: 0.04, blue: 0.04) // #0a0a0a
    static let secondaryBackground = Color(red: 0.1, green: 0.1, blue: 0.1) // #1a1a1a
    static let cardBackground = Color(red: 0.15, green: 0.15, blue: 0.15) // #262626
    
    static let primaryGreen = Color(red: 0, green: 0.78, blue: 0.32) // #00C851
    static let accentGreen = Color(red: 0, green: 0.6, blue: 0.25) // #009940
    static let lightGreen = Color(red: 0.2, green: 0.9, blue: 0.4) // #33E566
    
    static let textPrimary = Color(red: 0.94, green: 0.94, blue: 0.94) // #f0f0f0
    static let textSecondary = Color(red: 0.7, green: 0.7, blue: 0.7) // #b3b3b3
    static let textTertiary = Color(red: 0.5, green: 0.5, blue: 0.5) // #808080
    
    static let error = Color(red: 0.9, green: 0.2, blue: 0.2) // #e63333
    
    static let surfaceSecondary = Color(red: 0.12, green: 0.12, blue: 0.12) // #1f1f1f
}

extension View {
    func themedBackground() -> some View {
        self.background(ColorTheme.background.ignoresSafeArea())
    }
    
    func themedCard() -> some View {
        self
            .background(ColorTheme.cardBackground)
            .cornerRadius(12)
    }
}
