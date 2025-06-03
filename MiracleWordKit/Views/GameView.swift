import SwiftUI
import AVFoundation

struct GameView: View {
    @ObservedObject var gameModel: GameModel
    var levelToStart: Int? = nil
    @State private var audioPlayer: AVAudioPlayer?
    @Environment(\.presentationMode) var presentationMode
    @State private var showHint: Bool = false
    
    var body: some View {
        ZStack {
            CartoonBackground()
            VStack(spacing: 20) {
                // Timer
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.white)
                        .shadow(color: .blue, radius: 4, x: 0, y: 2)
                    Text("Time: \(gameModel.timeRemaining)s")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(gameModel.timeRemaining <= 5 ? .red : .white)
                        .shadow(color: .blue.opacity(0.5), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.7), .mint.opacity(0.7)]), startPoint: .leading, endPoint: .trailing))
                        )
                }
                .padding(.top)
                // Level number
                Text("Level \(gameModel.currentLevel + 1) of \(gameModel.levels.count)")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .shadow(color: .purple.opacity(0.5), radius: 4, x: 0, y: 2)
                // Hint (hidden by default)
                if showHint {
                    Text(gameModel.levels[gameModel.currentLevel].hint)
                        .font(.title3)
                        .foregroundColor(.yellow)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(gradient: Gradient(colors: [.yellow.opacity(0.7), .orange.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
                                .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    Text("Hint penalty: -10s")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else {
                    Button(action: {
                        gameModel.useHint()
                        if gameModel.hintUsed {
                            showHint = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text("Show Hint (")
                            + Text("\(gameModel.hintsLeft)").bold()
                            + Text(")")
                        }
                        .font(.title3)
                        .padding(10)
                        .background(
                            Capsule().fill(
                                gameModel.hintsLeft > 0
                                    ? AnyShapeStyle(LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .top, endPoint: .bottom))
                                    : AnyShapeStyle(Color.gray.opacity(0.2))
                            )
                        )
                        .shadow(color: .yellow.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .disabled(gameModel.hintsLeft == 0 || gameModel.hintUsed)
                    if gameModel.hintsLeft == 0 {
                        Text("No hints left!")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        Text("Hint penalty: -10s")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                // Word display
                let chars = Array(gameModel.currentWord)
                HStack(spacing: 12) {
                    ForEach(chars.indices, id: \.self) { idx in
                        CartoonLetterBox(
                            letter: String(chars[idx]),
                            revealed: gameModel.guessedLetters.contains(chars[idx])
                        )
                    }
                }
                .padding(.vertical, 8)
                // Attempts counter
                HStack(spacing: 8) {
                    ForEach(0..<gameModel.maxAttempts, id: \.self) { index in
                        Circle()
                            .fill(index < gameModel.incorrectAttempts ? Color.red : Color.green.opacity(0.2))
                            .frame(width: 24, height: 24)
                            .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
                            .overlay(
                                index < gameModel.incorrectAttempts ? Image(systemName: "xmark").foregroundColor(.white) : nil
                            )
                    }
                }
                // Letter grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 7), spacing: 10) {
                    ForEach(gameModel.getRemainingLetters(), id: \.self) { letter in
                        CartoonLetterButton(letter: letter) {
                            gameModel.guessLetter(letter)
                            if gameModel.currentWord.contains(letter) && gameModel.isSoundEnabled {
                                playCorrectFeedback()
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                // Game state message
                if gameModel.gameState != .playing {
                    VStack(spacing: 16) {
                        if gameModel.gameState == .timeout {
                            Text("Time's up! ⏰")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        } else if gameModel.gameState == .lost {
                            Text("Try again! 😢")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        } else {
                            Text(gameModel.gameState == .won ? "Great job! 🎉" : "Try again! 😢")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(gameModel.gameState == .won ? .green : .red)
                        }
                        if (gameModel.gameState == .lost || gameModel.gameState == .timeout) {
                            Button("Retry") {
                                gameModel.startLevel(gameModel.currentLevel)
                                showHint = false
                            }
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .buttonStyle(CartoonButtonStyle(gradient: Gradient(colors: [.orange, .pink]), shadow: .orange))
                            .padding(.horizontal, 32)
                        }
                        if gameModel.gameState == .won && gameModel.currentLevel < gameModel.levels.count - 1 {
                            Button("Next Level") {
                                gameModel.startNextLevel()
                            }
                            .buttonStyle(CartoonButtonStyle(gradient: Gradient(colors: [.mint, .yellow]), shadow: .yellow))
                        }
                        Button("Back to Levels") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .buttonStyle(CartoonButtonStyle(gradient: Gradient(colors: [.blue, .purple]), shadow: .purple))
                        .padding(.horizontal, 32)
                        .padding(.top, 4)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            if let lvl = levelToStart {
                gameModel.startLevel(lvl)
            } else {
                gameModel.startLevel(gameModel.currentLevel)
            }
            showHint = false
        }
    }
    
    private func playCorrectFeedback() {
        // Try to play sound
        if let soundURL = Bundle.main.url(forResource: "buble", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Could not play sound: \(error)")
                // Fallback to haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        } else {
            // Fallback to haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

struct CartoonLetterBox: View {
    let letter: String
    let revealed: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    revealed
                        ? AnyShapeStyle(LinearGradient(gradient: Gradient(colors: [.white, .yellow]), startPoint: .top, endPoint: .bottom))
                        : AnyShapeStyle(Color.white.opacity(0.2))
                )
                .frame(width: 44, height: 56)
                .shadow(color: revealed ? .yellow.opacity(0.5) : .gray.opacity(0.2), radius: 6, x: 0, y: 3)
            if revealed {
                Text(letter)
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundColor(.orange)
                    .shadow(color: .yellow.opacity(0.7), radius: 6, x: 0, y: 2)
                    .transition(.scale)
            } else {
                Text("?")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: revealed)
    }
}

struct CartoonLetterButton: View {
    let letter: Character
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(String(letter))
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    LinearGradient(gradient: Gradient(colors: [.pink, .purple, .blue]), startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(12)
                .shadow(color: .purple.opacity(0.4), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: false)
    }
} 