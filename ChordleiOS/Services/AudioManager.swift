import Foundation
import AVFoundation
import Combine

class AudioManager: NSObject, ObservableObject {
    @Published var isLoading = false
    @Published var isPlaying = false
    @Published var errorMessage: String?
    @Published var hasPlayedThisAttempt = false
    
    private var audioPlayers: [AVAudioPlayer] = []
    private var audioSession: AVAudioSession
    private var downloadTasks: [URLSessionDataTask] = []
    
    override init() {
        self.audioSession = AVAudioSession.sharedInstance()
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP, .duckOthers])
            try audioSession.setActive(true)
            print("[AudioManager] Audio session setup successful")
        } catch {
            print("[AudioManager] Failed to setup audio session: \(error)")
            errorMessage = "Audio setup failed: \(error.localizedDescription)"
        }
    }
    
    func playChord(_ chord: ChordType, hintType: GameManager.HintType = .chordNoFingers, audioOption: GameManager.AudioOption = .chord) {
        guard !isLoading && !hasPlayedThisAttempt else {
            print("[AudioManager] Blocked: isLoading=\(isLoading), hasPlayedThisAttempt=\(hasPlayedThisAttempt)")
            return
        }
        
        print("[AudioManager] 🎵 Playing chord: \(chord.rawValue) with hint: \(hintType), option: \(audioOption)")
        
        isLoading = true
        errorMessage = nil
        hasPlayedThisAttempt = true
        
        // Cancel any existing downloads
        downloadTasks.forEach { $0.cancel() }
        downloadTasks.removeAll()
        audioPlayers.removeAll()
        
        let stringFiles = chord.getStringFiles()
        print("[AudioManager] 📁 String files: \(stringFiles)")
        
        // Post notification for string shake animation
        NotificationCenter.default.post(name: NSNotification.Name("AudioStarted"), object: nil)
        
        switch hintType {
        case .chordNoFingers:
            print("[AudioManager] 🎸 Playing simultaneous chord")
            playChordSimultaneous(stringFiles: stringFiles)
        case .chordSlow:
            print("[AudioManager] 🐌 Playing chord slower (arpeggiated with 0.4s delay)")
            playStringSequence(stringFiles: stringFiles, delay: 0.4)
        case .individualStrings:
            print("[AudioManager] 🎼 Playing individual strings (1.0s delay)")
            playStringSequence(stringFiles: stringFiles, delay: 1.0)
        case .audioOptions:
            print("[AudioManager] 🎛️ Playing selected audio option: \(audioOption)")
            playSelectedAudioOption(stringFiles: stringFiles, option: audioOption)
        case .singleFingerReveal:
            print("[AudioManager] 👆 Playing chord with finger reveal")
            playChordSimultaneous(stringFiles: stringFiles)
        }
    }
    
    private func playChordSlower(stringFiles: [String]) {
        print("[AudioManager] 🐌 Playing chord slower")
        playStringSequence(stringFiles: stringFiles, delay: 0.4)
    }
    
    private func playSelectedAudioOption(stringFiles: [String], option: GameManager.AudioOption) {
        print("[AudioManager] Playing option: \(option.rawValue) with files: \(stringFiles)")
        
        switch option {
        case .chord:
            playChordSimultaneous(stringFiles: stringFiles)
        case .arpeggiated:
            playStringSequence(stringFiles: stringFiles, delay: 0.12) // Quick arpeggiated
        case .individual:
            playStringSequence(stringFiles: stringFiles, delay: 0.5)  // Faster individual
        case .bass:
            let bassStrings = Array(stringFiles.prefix(stringFiles.count / 2))
            print("[AudioManager] Playing bass strings: \(bassStrings)")
            playChordSimultaneous(stringFiles: bassStrings)
        case .treble:
            let trebleStrings = Array(stringFiles.suffix(stringFiles.count / 2))
            print("[AudioManager] Playing treble strings: \(trebleStrings)")
            playChordSimultaneous(stringFiles: trebleStrings)
        }
    }
    
    private func playChordSimultaneous(stringFiles: [String]) {
        let group = DispatchGroup()
        var audioDataArray: [(Data, Int)] = []
        
        for (index, fileName) in stringFiles.enumerated() {
            group.enter()
            let url = "https://raw.githubusercontent.com/mmaaseide23/Chordle_Assets/main/\(fileName)"
            
            guard let audioURL = URL(string: url) else {
                group.leave()
                continue
            }
            
            let task = URLSession.shared.dataTask(with: audioURL) { data, response, error in
                defer { group.leave() }
                
                if let data = data, error == nil {
                    audioDataArray.append((data, index))
                }
            }
            
            downloadTasks.append(task)
            task.resume()
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
            self.playSimultaneousAudio(audioDataArray.sorted { $0.1 < $1.1 }.map { $0.0 })
        }
    }
    
    private func playChordArpeggiated(stringFiles: [String]) {
        playStringSequence(stringFiles: stringFiles, delay: 0.2)
    }
    
    private func playIndividualStrings(stringFiles: [String]) {
        playStringSequence(stringFiles: stringFiles, delay: 1.0)
    }
    
    private func playFretHints(chord: ChordType) {
        // Play a simplified version focusing on key finger positions
        let keyPositions = Array(chord.getStringFiles().prefix(3))
        playStringSequence(stringFiles: keyPositions, delay: 0.8)
    }
    
    private func playStringSequence(stringFiles: [String], delay: Double) {
        print("[AudioManager] 🔄 Starting string sequence with \(stringFiles.count) files, delay: \(delay)s")
        isLoading = false
        
        guard !stringFiles.isEmpty else {
            print("[AudioManager] ❌ No string files to play")
            isPlaying = false
            return
        }
        
        // Stop any existing audio first
        audioPlayers.forEach { $0.stop() }
        audioPlayers.removeAll()
        
        var currentPlayer: AVAudioPlayer?
        
        func playNext(index: Int) {
            guard index < stringFiles.count else {
                print("[AudioManager] ✅ Sequence complete")
                DispatchQueue.main.async {
                    self.isPlaying = false
                }
                return
            }
            
            let fileName = stringFiles[index]
            let url = "https://raw.githubusercontent.com/mmaaseide23/Chordle_Assets/main/\(fileName)"
            print("[AudioManager] 🎵 Playing string \(index + 1)/\(stringFiles.count): \(fileName)")
            
            guard let audioURL = URL(string: url) else {
                print("[AudioManager] ❌ Invalid URL for: \(fileName)")
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    playNext(index: index + 1)
                }
                return
            }
            
            let task = URLSession.shared.dataTask(with: audioURL) { data, response, error in
                if let error = error {
                    print("[AudioManager] ❌ Download error for \(fileName): \(error.localizedDescription)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        playNext(index: index + 1)
                    }
                    return
                }
                
                guard let data = data else {
                    print("[AudioManager] ❌ No data received for \(fileName)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        playNext(index: index + 1)
                    }
                    return
                }
                
                print("[AudioManager] ✅ Downloaded \(fileName) (\(data.count) bytes)")
                
                DispatchQueue.main.async {
                    // Stop previous player
                    currentPlayer?.stop()
                    
                    do {
                        currentPlayer = try AVAudioPlayer(data: data)
                        currentPlayer?.delegate = self
                        currentPlayer?.volume = 1.0
                        
                        guard let player = currentPlayer, player.prepareToPlay() else {
                            print("[AudioManager] ❌ Failed to prepare audio for playback")
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                playNext(index: index + 1)
                            }
                            return
                        }
                        
                        if player.play() {
                            print("[AudioManager] ✅ Audio playback started successfully")
                            // Wait for this audio to finish before playing next
                            let audioDuration = player.duration
                            let actualDelay: Double
                            
                            if delay <= 0.2 {
                                // For arpeggiated (fast), overlap the sounds slightly
                                actualDelay = delay
                            } else {
                                // For individual strings, wait for audio to mostly finish
                                actualDelay = max(delay * 0.6, audioDuration * 0.8)
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + actualDelay) {
                                playNext(index: index + 1)
                            }
                        } else {
                            print("[AudioManager] ❌ Failed to start audio playback")
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                playNext(index: index + 1)
                            }
                        }
                    } catch {
                        print("[AudioManager] ❌ Audio creation error: \(error.localizedDescription)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            playNext(index: index + 1)
                        }
                    }
                }
            }
            
            downloadTasks.append(task)
            task.resume()
        }
        
        DispatchQueue.main.async {
            self.isPlaying = true
            playNext(index: 0)
        }
    }

    
    private func playSimultaneousAudio(_ audioDataArray: [Data]) {
        audioPlayers.removeAll()
        
        for data in audioDataArray {
            do {
                let player = try AVAudioPlayer(data: data)
                player.delegate = self
                player.volume = 0.8 // Slightly lower volume for multiple sounds
                player.prepareToPlay()
                audioPlayers.append(player)
            } catch {
                print("[AudioManager] Failed to create player: \(error)")
            }
        }
        
        // Start all players simultaneously
        let startTime = audioPlayers.first?.deviceCurrentTime ?? 0
        let playTime = startTime + 0.01 // Small delay to sync
        
        for player in audioPlayers {
            player.play(atTime: playTime)
        }
        
        if !audioPlayers.isEmpty {
            isPlaying = true
        }
    }
    
    func resetForNewAttempt() {
        hasPlayedThisAttempt = false
    }
    
    private func playAudioData(_ data: Data) {
        do {
            let player = try AVAudioPlayer(data: data)
            player.delegate = self
            player.volume = 1.0
            
            guard player.prepareToPlay() else {
                print("[AudioManager] ❌ Failed to prepare audio for playback")
                errorMessage = "Failed to prepare audio for playback"
                return
            }
            
            if player.play() {
                print("[AudioManager] ✅ Audio playback started successfully")
                // Don't set isPlaying here for sequential playback
            } else {
                print("[AudioManager] ❌ Failed to start audio playback")
                errorMessage = "Failed to start audio playback"
            }
        } catch {
            print("[AudioManager] ❌ Audio playback error: \(error.localizedDescription)")
            errorMessage = "Playback error: \(error.localizedDescription)"
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.errorMessage = "Audio decode error: \(error?.localizedDescription ?? "Unknown error")"
        }
    }
}
