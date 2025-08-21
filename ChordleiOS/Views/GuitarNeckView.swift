import SwiftUI

struct GuitarNeckView: View {
    let chord: ChordType?
    let currentAttempt: Int
    let jumbledPositions: [Int]
    let revealedFingerIndex: Int
    
    @State private var animateFingers = false
    @State private var showStrings = false
    @State private var stringShake = false
    
    var shouldShowFingers: Bool {
        return currentAttempt >= 5
    }
    
    var shouldShowJumbledFingers: Bool {
        return currentAttempt == 5 && !jumbledPositions.isEmpty
    }
    
    var shouldShowRevealedFinger: Bool {
        return currentAttempt == 6 && revealedFingerIndex >= 0
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Neck background
                neckBackground
                
                // Fret wires (vertical lines)
                FretWiresView()
                
                // Fret position markers (dots on neck)
                FretMarkersView()
                
                // Guitar strings (horizontal lines)
                StringsView(showStrings: showStrings, stringShake: stringShake)
                
                if let chord = chord, shouldShowFingers {
                    if shouldShowJumbledFingers {
                        JumbledFingeringView(
                            chord: chord,
                            jumbledPositions: jumbledPositions,
                            animate: animateFingers
                        )
                    } else if shouldShowRevealedFinger {
                        RevealedFingerView(
                            chord: chord,
                            revealedIndex: revealedFingerIndex,
                            animate: animateFingers
                        )
                    } else {
                        ChordFingeringView(chord: chord, animate: animateFingers)
                    }
                }
            }
            .frame(width: 350, height: 280)
        }
        .onAppear {
            showStrings = true
            if chord != nil && shouldShowFingers {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    animateFingers = true
                }
            }
        }
        .onChange(of: chord) { oldValue, newValue in
            if newValue != nil {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showStrings = true
                }
                
                if shouldShowFingers {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            animateFingers = true
                        }
                    }
                }
            } else {
                animateFingers = false
            }
        }
        .onChange(of: currentAttempt) { oldValue, newValue in
            animateFingers = false
            if shouldShowFingers {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        animateFingers = true
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .triggerStringShake)) { _ in
            triggerStringShake()
        }
    }
    
    private var neckBackground: some View {
        let woodGradient = LinearGradient(
            colors: [
                Color(red: 0.35, green: 0.2, blue: 0.1),   // Darker wood
                Color(red: 0.45, green: 0.3, blue: 0.15),  // Medium wood
                Color(red: 0.4, green: 0.25, blue: 0.12),  // Rich wood
                Color(red: 0.5, green: 0.35, blue: 0.2),   // Lighter wood
                Color(red: 0.4, green: 0.25, blue: 0.12)   // Back to rich wood
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Wood grain effect
        let grainOverlay = LinearGradient(
            colors: [
                Color.black.opacity(0.1),
                Color.clear,
                Color.black.opacity(0.05),
                Color.clear,
                Color.black.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        return RoundedRectangle(cornerRadius: 12)
            .fill(woodGradient)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .fill(grainOverlay)
            )
            .frame(width: 320, height: 250)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [Color.black.opacity(0.4), Color.black.opacity(0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
    
    func triggerStringShake() {
        stringShake = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            stringShake = false
        }
    }
}

// Fret wires - these are the metal strips that run vertically across the neck
struct FretWiresView: View {
    let fretSpacing: [CGFloat] = [0, 55, 100, 140, 175, 205] // More realistic fret spacing (left to right)
    
    var body: some View {
        ZStack {
            // Nut (at position 0 - the thick line at the left)
            Rectangle()
                .fill(LinearGradient(
                    colors: [
                        Color.white,
                        Color.gray.opacity(0.9),
                        Color.white,
                        Color.gray.opacity(0.7)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: 8, height: 200)
                .position(x: 50 + fretSpacing[0], y: 125)
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 2, height: 200)
                        .position(x: 50 + fretSpacing[0], y: 125)
                )
                .shadow(color: .black.opacity(0.5), radius: 2, x: 2, y: 0)
                .shadow(color: .white.opacity(0.4), radius: 1, x: -1, y: 0)
            
            // Fret wires (positions 1-5) - VERTICAL lines
            ForEach(1..<fretSpacing.count, id: \.self) { fretIndex in
                Rectangle()
                    .fill(LinearGradient(
                        colors: [
                            Color.silver.opacity(0.9),
                            Color.white,
                            Color.silver.opacity(0.9)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: 2.5, height: 200)
                    .position(x: 50 + fretSpacing[fretIndex], y: 125)
                    .shadow(color: .black.opacity(0.5), radius: 1, x: 1, y: 0)
            }
        }
        .frame(width: 320, height: 250)
    }
}

// Fret position markers - dots on the fretboard between frets
struct FretMarkersView: View {
    var body: some View {
        ZStack {
            // 3rd fret marker (moved down one fret - now between 3rd and 4th fret)
            Circle()
                .fill(RadialGradient(
                    colors: [Color.white.opacity(0.8), Color.gray.opacity(0.4)],
                    center: .center,
                    startRadius: 2,
                    endRadius: 6
                ))
                .frame(width: 12, height: 12)
                .position(x: 50 + 120, y: 125) // Between 3rd and 4th fret
                .shadow(color: .black.opacity(0.2), radius: 1)
            
            // 5th fret marker (moved down one fret - now between 5th and 6th fret)
            Circle()
                .fill(RadialGradient(
                    colors: [Color.white.opacity(0.8), Color.gray.opacity(0.4)],
                    center: .center,
                    startRadius: 2,
                    endRadius: 6
                ))
                .frame(width: 12, height: 12)
                .position(x: 50 + 190, y: 125) // Between 5th and 6th fret
                .shadow(color: .black.opacity(0.2), radius: 1)
        }
        .frame(width: 320, height: 250)
    }
}

// Guitar strings - horizontal lines across the fretboard
struct StringsView: View {
    let showStrings: Bool
    let stringShake: Bool
    
    // String positions - more centered and better spaced
    let stringPositions: [CGFloat] = [75, 95, 115, 135, 155, 175]
    
    var body: some View {
        ZStack {
            ForEach(0..<6) { stringIndex in
                StringView(
                    stringIndex: stringIndex,
                    yPosition: stringPositions[stringIndex],
                    showStrings: showStrings,
                    stringShake: stringShake
                )
            }
        }
        .frame(width: 320, height: 250)
    }
}

// Individual string
struct StringView: View {
    let stringIndex: Int
    let yPosition: CGFloat
    let showStrings: Bool
    let stringShake: Bool
    
    private var stringColors: [Color] {
        [
            Color(red: 0.7, green: 0.6, blue: 0.3),   // Low E (thickest, bronze-ish)
            Color(red: 0.75, green: 0.65, blue: 0.35), // A
            Color(red: 0.8, green: 0.7, blue: 0.4),   // D
            Color(red: 0.85, green: 0.75, blue: 0.45), // G
            Color(red: 0.9, green: 0.8, blue: 0.5),   // B
            Color(red: 0.9, green: 0.8, blue: 0.5)    // High E (thinnest, brighter)
        ]
    }
    
    private var stringWidths: [CGFloat] {
        [2.5, 2.0, 1.8, 1.5, 1.2, 1.0] // More realistic string thickness progression
    }
    
    var body: some View {
        let stringGradient = LinearGradient(
            colors: [
                stringColors[stringIndex].opacity(0.6),
                stringColors[stringIndex],
                stringColors[stringIndex].opacity(0.8)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        
        let scaleX = showStrings ? (stringShake ? 1.1 : 1.0) : 0.9
        let scaleY = showStrings ? (stringShake ? 1.2 : 1.0) : 0.8
        let offsetX = stringShake ? CGFloat.random(in: -2...2) : 0
        let offsetY = stringShake ? CGFloat.random(in: -0.5...0.5) : 0
        
        let animation = stringShake ?
            Animation.easeInOut(duration: 0.08).repeatCount(8, autoreverses: true) :
            Animation.easeInOut(duration: 0.3)
        
        return Rectangle()
            .fill(stringGradient)
            .frame(width: 230, height: stringWidths[stringIndex]) // Slightly longer strings
            .position(x: 160, y: yPosition)
            .scaleEffect(x: scaleX, y: scaleY)
            .offset(x: offsetX, y: offsetY)
            .animation(animation, value: stringShake)
            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
            .shadow(color: stringColors[stringIndex].opacity(0.3), radius: 2, x: 0, y: 0)
    }
}

struct ChordFingeringView: View {
    let chord: ChordType
    let animate: Bool
    
    var fingerPositions: [(string: Int, fret: Int)] {
        let positions = chord.fingerPositions
        let stringMap = ["E2": 0, "A3": 1, "D3": 2, "G3": 3, "B4": 4, "E4": 5]
        
        return positions.compactMap { position in
            if let stringIndex = stringMap[position.string], position.fret > 0 {
                return (stringIndex, position.fret)
            }
            return nil
        }
    }
    
    var body: some View {
        ZStack {
            ForEach(Array(fingerPositions.enumerated()), id: \.offset) { index, position in
                FingerDotView(
                    position: position,
                    animate: animate,
                    index: index
                )
            }
        }
        .frame(width: 320, height: 250)
    }
}

// Finger position dots
struct FingerDotView: View {
    let position: (string: Int, fret: Int)
    let animate: Bool
    let index: Int
    
    // String positions matching updated StringsView
    let stringPositions: [CGFloat] = [75, 95, 115, 135, 155, 175]
    // Fret positions - ON the frets for finger placement
    let fretPositions: [CGFloat] = [55, 100, 140, 175, 205]
    
    var body: some View {
        let fingerGradient = RadialGradient(
            colors: [
                Color.white.opacity(0.3),
                ColorTheme.primaryGreen.opacity(0.9),
                ColorTheme.primaryGreen,
                ColorTheme.primaryGreen.opacity(0.8)
            ],
            center: UnitPoint(x: 0.3, y: 0.3), // Offset center for 3D effect
            startRadius: 2,
            endRadius: 14
        )
        
        let size = animate ? 26.0 : 18.0
        let strokeWidth = animate ? 2.5 : 1.5
        let strokeOpacity = animate ? 1.0 : 0.6
        let glowSize = animate ? 38.0 : 28.0
        let glowOpacity = animate ? 0.5 : 0.0
        let scale = animate ? 1.0 : 0.75
        let opacity = animate ? 1.0 : 0.7
        
        // Calculate positions
        let fretIndex = min(position.fret - 1, fretPositions.count - 1)
        let xPosition: CGFloat = 50 + fretPositions[fretIndex]
        let yPosition = stringPositions[position.string]
        let animationDelay = Double(index) * 0.1
        
        return Circle()
            .fill(fingerGradient)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [ColorTheme.lightGreen, ColorTheme.lightGreen.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: strokeWidth
                    )
                    .opacity(strokeOpacity)
            )
            .overlay(
                Circle()
                    .fill(ColorTheme.lightGreen.opacity(0.15))
                    .frame(width: glowSize, height: glowSize)
                    .blur(radius: 8)
                    .opacity(glowOpacity)
            )
            .position(x: xPosition, y: yPosition)
            .scaleEffect(scale)
            .opacity(opacity)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.7)
                .delay(animationDelay),
                value: animate
            )
            .shadow(color: .black.opacity(0.4), radius: 3, x: 1, y: 2)
            .shadow(color: ColorTheme.primaryGreen.opacity(0.3), radius: 6, x: 0, y: 0)
    }
}

struct JumbledFingeringView: View {
    let chord: ChordType
    let jumbledPositions: [Int]
    let animate: Bool
    
    var body: some View {
        ZStack {
            ForEach(Array(jumbledPositions.enumerated()), id: \.offset) { index, position in
                JumbledFingerDotView(
                    position: position,
                    animate: animate,
                    index: index
                )
            }
        }
        .frame(width: 320, height: 250)
    }
}

struct RevealedFingerView: View {
    let chord: ChordType
    let revealedIndex: Int
    let animate: Bool
    
    var fingerPositions: [(string: Int, fret: Int)] {
        let positions = chord.fingerPositions
        let stringMap = ["E2": 0, "A3": 1, "D3": 2, "G3": 3, "B4": 4, "E4": 5]
        
        return positions.compactMap { position in
            if let stringIndex = stringMap[position.string], position.fret > 0 {
                return (stringIndex, position.fret)
            }
            return nil
        }
    }
    
    var body: some View {
        ZStack {
            if revealedIndex < fingerPositions.count {
                let position = fingerPositions[revealedIndex]
                RevealedFingerDotView(
                    position: position,
                    animate: animate
                )
            }
        }
        .frame(width: 320, height: 250)
    }
}

struct JumbledFingerDotView: View {
    let position: Int
    let animate: Bool
    let index: Int
    
    let stringPositions: [CGFloat] = [75, 95, 115, 135, 155, 175]
    let fretPositions: [CGFloat] = [55, 100, 140, 175, 205]
    
    var body: some View {
        let fingerGradient = RadialGradient(
            colors: [
                Color.orange.opacity(0.3),
                Color.orange.opacity(0.7),
                Color.orange,
                Color.orange.opacity(0.8)
            ],
            center: UnitPoint(x: 0.3, y: 0.3),
            startRadius: 2,
            endRadius: 14
        )
        
        let size = animate ? 24.0 : 16.0
        let scale = animate ? 1.0 : 0.75
        let opacity = animate ? 0.8 : 0.5
        
        // Random position for jumbled effect
        let randomString = Int.random(in: 0..<6)
        let randomFret = Int.random(in: 0..<5)
        let xPosition: CGFloat = 50 + fretPositions[randomFret]
        let yPosition = stringPositions[randomString]
        let animationDelay = Double(index) * 0.15
        
        return Circle()
            .fill(fingerGradient)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(Color.orange.opacity(0.6), lineWidth: 1.5)
            )
            .position(x: xPosition, y: yPosition)
            .scaleEffect(scale)
            .opacity(opacity)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.7)
                .delay(animationDelay),
                value: animate
            )
            .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
    }
}

struct RevealedFingerDotView: View {
    let position: (string: Int, fret: Int)
    let animate: Bool
    
    let stringPositions: [CGFloat] = [75, 95, 115, 135, 155, 175]
    let fretPositions: [CGFloat] = [55, 100, 140, 175, 205]
    
    var body: some View {
        let fingerGradient = RadialGradient(
            colors: [
                Color.yellow.opacity(0.3),
                ColorTheme.primaryGreen.opacity(0.9),
                ColorTheme.primaryGreen,
                ColorTheme.primaryGreen.opacity(0.8)
            ],
            center: UnitPoint(x: 0.3, y: 0.3),
            startRadius: 2,
            endRadius: 16
        )
        
        let size = animate ? 30.0 : 20.0
        let glowSize = animate ? 45.0 : 35.0
        let scale = animate ? 1.0 : 0.75
        
        let fretIndex = min(position.fret - 1, fretPositions.count - 1)
        let xPosition: CGFloat = 50 + fretPositions[fretIndex]
        let yPosition = stringPositions[position.string]
        
        return Circle()
            .fill(fingerGradient)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(Color.yellow, lineWidth: 3)
                    .opacity(0.8)
            )
            .overlay(
                Circle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: glowSize, height: glowSize)
                    .blur(radius: 10)
                    .opacity(0.6)
            )
            .position(x: xPosition, y: yPosition)
            .scaleEffect(scale)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animate)
            .shadow(color: .yellow.opacity(0.5), radius: 8, x: 0, y: 0)
            .shadow(color: .black.opacity(0.4), radius: 3, x: 1, y: 2)
    }
}

extension Color {
    static let silver = Color(red: 0.8, green: 0.8, blue: 0.8)
}

extension Notification.Name {
    static let triggerStringShake = Notification.Name("triggerStringShake")
}

#Preview {
    VStack {
        GuitarNeckView(chord: .cMajor, currentAttempt: 5, jumbledPositions: [1, 2, 3], revealedFingerIndex: -1)
        GuitarNeckView(chord: .cMajor, currentAttempt: 6, jumbledPositions: [], revealedFingerIndex: 0)
        GuitarNeckView(chord: nil, currentAttempt: 4, jumbledPositions: [], revealedFingerIndex: -1)
    }
    .themedBackground()
}
