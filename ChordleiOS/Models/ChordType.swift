import Foundation

enum ChordType: String, CaseIterable, Identifiable {
    case cMajor = "C"
    case dMajor = "D"
    case eMajor = "E"
    case fMajor = "F"
    case gMajor = "G"
    case aMajor = "A"
    case bMajor = "B"
    case cMinor = "Cm"
    case dMinor = "Dm"
    case eMinor = "Em"
    case fMinor = "Fm"
    case gMinor = "Gm"
    case aMinor = "Am"
    case bMinor = "Bm"
    
    var id: String { rawValue }
    
    var displayName: String {
        return rawValue
    }
    
    var audioFileName: String {
        switch self {
        case .cMajor: return "C_major.m4a"
        case .dMajor: return "D_major.m4a"
        case .eMajor: return "E_major.m4a"
        case .fMajor: return "F_major.m4a"
        case .gMajor: return "G_major.m4a"
        case .aMajor: return "A_major.m4a"
        case .bMajor: return "B_major.m4a"
        case .cMinor: return "C_minor.m4a"
        case .dMinor: return "D_minor.m4a"
        case .eMinor: return "E_minor.m4a"
        case .fMinor: return "F_minor.m4a"
        case .gMinor: return "G_minor.m4a"
        case .aMinor: return "A_minor.m4a"
        case .bMinor: return "B_minor.m4a"
        }
    }
    
    func audioFileName(for hintType: GameManager.HintType) -> String {
        switch hintType {
        case .chordNoFingers, .chordSlow, .audioOptions, .singleFingerReveal:
            return getStringFiles().first ?? "E2_fret0.m4a"
        case .individualStrings:
            return getStringFiles().first ?? "E2_fret0.m4a"
        default:
            return audioFileName
        }
    }
    
    var githubURL: String {
        return githubURL(for: .chordNoFingers)
    }
    
    func githubURL(for hintType: GameManager.HintType) -> String {
        return "https://raw.githubusercontent.com/mmaaseide23/Chordle_Assets/main/\(audioFileName(for: hintType))"
    }
    
    var fingerPositions: [(string: String, fret: Int)] {
        switch self {
        case .cMajor:
            return [("A3", 3), ("D3", 2), ("G3", 0), ("B4", 1), ("E4", 0)]
        case .dMajor:
            return [("D3", 0), ("G3", 2), ("B4", 3), ("E4", 2)]
        case .eMajor:
            return [("E2", 0), ("A3", 2), ("D3", 2), ("G3", 1), ("B4", 0), ("E4", 0)]
        case .fMajor:
            return [("E2", 1), ("A3", 3), ("D3", 3), ("G3", 2), ("B4", 1), ("E4", 1)]
        case .gMajor:
            return [("E2", 3), ("A3", 2), ("D3", 0), ("G3", 0), ("B4", 3), ("E4", 3)]
        case .aMajor:
            return [("A3", 0), ("D3", 2), ("G3", 2), ("B4", 2), ("E4", 0)]
        case .bMajor:
            return [("A3", 2), ("D3", 4), ("G3", 4), ("B4", 4), ("E4", 2)]
        case .cMinor:
            return [("A3", 3), ("D3", 1), ("G3", 0), ("B4", 4), ("E4", 3)]
        case .dMinor:
            return [("D3", 0), ("G3", 2), ("B4", 3), ("E4", 1)]
        case .eMinor:
            return [("E2", 0), ("A3", 2), ("D3", 2), ("G3", 0), ("B4", 0), ("E4", 0)]
        case .fMinor:
            return [("E2", 1), ("A3", 3), ("D3", 3), ("G3", 1), ("B4", 1), ("E4", 1)]
        case .gMinor:
            return [("E2", 3), ("A3", 1), ("D3", 0), ("G3", 0), ("B4", 3), ("E4", 3)]
        case .aMinor:
            return [("A3", 0), ("D3", 2), ("G3", 2), ("B4", 1), ("E4", 0)]
        case .bMinor:
            return [("A3", 2), ("D3", 4), ("G3", 4), ("B4", 3), ("E4", 2)]
        }
    }
    
    func getStringFiles() -> [String] {
        return fingerPositions.map { "\($0.string)_fret\($0.fret).m4a" }
    }
}
