import SwiftUI
import SwiftData
import AVFoundation


struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    // Tempo dropdown
    @State private var selectedTempo: String = "Practice Tempo"
    private let tempoOptions = ["Practice Tempo", "Championship Tempo", "Long Drive Tempo"]
    
    // Pendulum animation state
    @State private var angle: Double = -30
    @State private var swingRight = true
    @State private var isAnimating = false
    @State private var timer: Timer?
    
    @State private var showingInfo = false
    
    //Music
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Dropdown
                Picker("Select Tempo", selection: $selectedTempo) {
                    ForEach(tempoOptions, id: \.self) { tempo in
                        Text(tempo)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Metronome + Arm
                ZStack {
                    // Static metronome body
                    Image("metronome")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 360, height: 400)

                    // Enlarged and aligned pendulum arm
                    Image("metronomeBlack") // should point straight up
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 200)
                        .offset(y: -35)
                        .rotationEffect(.degrees(angle), anchor: .bottom)
                        .animation(.easeInOut(duration: animationDuration()), value: angle)
                }

                // Start
                Button(action: {
                    startSwing()
                }) {
                    Text("Start")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Stop
                Button(action: {
                    stopSwing()
                }) {
                    Text("Stop")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingInfo = true
                    }) {
                        Image(systemName: "info.circle")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showingInfo) {
                InfoView()
            }
            .navigationTitle("Golf Metronome")
            .onDisappear {
                stopSwing()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                startSwing()
            }
        }
    }

    
    // Tempo speed
    private func animationDuration() -> Double {
        switch selectedTempo {
        case "Practice Tempo": return 0.6
        case "Championship Tempo": return 0.4
        case "Long Drive Tempo": return 0.25
        default: return 0.6
        }
    }
    
    // Start swing
    private func startSwing() {
        if isAnimating { return }
        isAnimating = true

        setupAudioSession()

        angle = swingRight ? 30 : -30
        swingRight.toggle()

        timer = Timer.scheduledTimer(withTimeInterval: animationDuration(), repeats: true) { _ in
            withAnimation(.easeInOut(duration: animationDuration())) {
                angle = swingRight ? 30 : -30
                swingRight.toggle()
            }
        }

        if selectedTempo == "Long Drive Tempo" {
            playFullSong()
        } else {
            playLoopedSound()
        }
    }


    // Stop swing
    private func stopSwing() {
        timer?.invalidate()
        timer = nil
        isAnimating = false
        angle = -30
        swingRight = true
        audioPlayer?.stop()
        audioPlayer = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    private var selectedSound: (name: String, ext: String) {
        let map: [String: (String, String)] = [
            "Practice Tempo": ("practice", "mp3"),
            "Championship Tempo": ("champion", "mp3"),
            "Long Drive Tempo": ("long", "mp3")
        ]
        return map[selectedTempo] ?? ("practice", "mp3")
    }
    
    
    
    private func playTickSound() {
        setupAudioSession()
        let sound = selectedSound
        print("🔁 Playing sound: \(sound.name).\(sound.ext)")
        
        guard let url = Bundle.main.url(forResource: sound.name, withExtension: sound.ext) else {
            print("❌ Sound file not found: \(sound.name).\(sound.ext)")
            return
        }
        
        do {
            // Stop any currently playing sound
            audioPlayer?.stop()
            
            // Reinitialize player with fresh sound
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("❌ Failed to play sound: \(error)")
        }
    }
    
    private func playFullSong() {
        setupAudioSession()
        let sound = selectedSound
        print("🎵 Playing full song: \(sound.name).\(sound.ext)")
        
        guard let url = Bundle.main.url(forResource: sound.name, withExtension: sound.ext) else {
            print("❌ Sound file not found: \(sound.name).\(sound.ext)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("❌ Failed to play full song: \(error)")
        }
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true, options: [])
        } catch {
            print("❌ Failed to activate audio session: \(error)")
        }
    }
    
    private func playLoopedSound() {
        let sound = selectedSound

        guard let url = Bundle.main.url(forResource: sound.name, withExtension: sound.ext) else {
            print("❌ Sound file not found: \(sound.name).\(sound.ext)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // infinite loop
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("❌ Failed to play sound: \(error)")
        }
    }
}
